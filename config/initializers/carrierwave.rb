CarrierWave.configure do |config|
  config.asset_host = Rails.application.secrets.domain_protocol + '://' + Rails.application.secrets.domain_name
end
