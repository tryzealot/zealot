# frozen_string_literal: true

class Admin::ServiceController < ApplicationController

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

  private

  def client
    @client ||= PumaControlClient.new
  end
end
