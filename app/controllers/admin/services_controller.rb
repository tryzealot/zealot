# frozen_string_literal: true

class Admin::ServicesController < ApplicationController
  respond_to :json

  SmtpConfigurationError = Class.new(StandardError)

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
    ensure_smtp_configuration!
    verify_smtp_credentials!

    respond_with_flash(
      flash_key: :notice,
      message: t('.success'),
      status: :ok,
      body: { message: 'ok' }
    )
  rescue SmtpConfigurationError => e
    respond_with_flash(
      flash_key: :alert,
      message: e.message,
      status: :bad_request
    )
  rescue => e
    respond_with_flash(
      flash_key: :alert,
      message: e.message,
      status: :forbidden
    )
  end

  private

  def render_unauthorized_smtp(exception)
    respond_with_error(401, exception)
  end

  def client
    @client ||= PumaControlClient.new
  end

  def ensure_smtp_configuration!
    raise SmtpConfigurationError, t('.smtp_method_only') unless Setting.mailer_method.to_sym == :smtp
    raise SmtpConfigurationError, t('.no_mailer_configuration') if Setting.mailer_options.blank?
  end

  def verify_smtp_credentials!
    options = smtp_options
    Net::SMTP.start(options[:address], options[:port]) do |smtp|
      smtp.enable_starttls if options[:enable_starttls]

      auth_method = options[:auth_method].presence || 'plain'
      smtp.authenticate(
        options[:user_name],
        options[:password],
        auth_method == 'none' ? nil : auth_method.to_sym
      ).success?
    end
  end

  def smtp_options
    @smtp_options ||= Setting.mailer_options.to_h.symbolize_keys
  end

  def respond_with_flash(flash_key:, message:, status:, body: { message: message })
    flash.now[flash_key] = message
    respond_to do |format|
      format.html { render json: body, status: status }
      format.json { render json: body, status: status }
      format.turbo_stream
    end
  end
end
