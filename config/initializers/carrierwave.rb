# frozen_string_literal: true

CarrierWave.configure do |config|
  url_options = Rails.configuration.x.url_options

  config.asset_host = "#{url_options[:protocol]}#{url_options[:host]}"
end
