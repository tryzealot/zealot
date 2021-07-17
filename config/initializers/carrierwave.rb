# frozen_string_literal: true

CarrierWave.configure do |config|
  url_options = Zealot.config.url_options
  config.asset_host = "#{url_options[:protocol]}#{url_options[:host]}"
  config.cache_dir = Rails.root.join('tmp', 'uploads', Rails.env)
end
