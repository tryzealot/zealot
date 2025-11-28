# frozen_string_literal: true

class Admin::ServicesController < ApplicationController
  respond_to :json

  def restart
    client.restart
    render json: { request: 'accepted' }
  end

  def status
    client.stats
    render json: { health: 'ok' }, status: :ok
  rescue
    render json: { health: 'fail' }, status: :internal_server_error
  end

  def smtp_verify
    if Setting.mailer_method.to_sym != :smtp
      message = t('.smtp_method_only')
      flash.now[:alert] = message
      return render json: { message: message }, status: :bad_request
    end

    if Setting.mailer_options.blank?
      message = t('.no_mailer_configuration')
      flash.now[:alert] = message
      return render json: { message: message }, status: :bad_request
    end 
    
    address = Setting.mailer_options[:address]
    port = Setting.mailer_options[:port]
    starttls = Setting.mailer_options[:enable_starttls]
    Net::SMTP.start(address, port) do |smtp|
      smtp.enable_starttls if starttls

      auth_method = Setting.mailer_options[:auth_method].presence || 'plain'
      smtp.authenticate(
        Setting.mailer_options[:user_name],
        Setting.mailer_options[:password],
        auth_method == 'none' ? nil : auth_method.to_sym
      ).success?
    end

    render json: { message: 'ok' }, status: :ok
  rescue => e
    render json: { message: e.message }, status: :forbidden
  end

  private

  def render_unauthorized_smtp(exception)
    respond_with_error(401, exception)
  end

  def client
    @client ||= PumaControlClient.new
  end
end
