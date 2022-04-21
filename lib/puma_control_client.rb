# frozen_string_literal: true

require 'faraday'

class PumaControlClient
  def initialize(url = nil, token: nil)
    @uri ||= ENV.fetch('PUMA_CONTROL_URL') { '0.0.0.0:9293' }
    @token ||= ENV.fetch('PUMA_CONTROL_URL_TOKEN') { 'zealot' }
  end

  def stats
    get 'stats'
  rescue Faraday::Error
    false
  end

  def restart
    get 'restart'
  end

  private

  def get(path)
    client.get(path, auth_token).body
  end

  def auth_token
    @auth_token ||= {
      token: @token
    }
  end

  def client
    @client ||= Faraday.new(url: "http://#{@uri}") do |f|
      f.response :logger if Rails.env.development?
      f.response :json
    end
  end
end