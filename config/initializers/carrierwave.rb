# frozen_string_literal: true

Rails.configuration.to_prepare do
  CarrierWave.configure do |config|
    url_options = Setting.url_options
    config.asset_host = "#{url_options[:protocol]}#{url_options[:host]}"
    config.cache_dir = Rails.root.join('tmp', 'uploads', Rails.env)
  end
end