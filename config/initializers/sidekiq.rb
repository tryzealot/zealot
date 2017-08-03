sidekiq_config_url = ENV['ACTIVE_JOB_URL'] || 'redis://localhost:6379/0'

Sidekiq.configure_server do |config|
  config.redis = {
    url: sidekiq_config_url,
    namespace: 'qyer:mobile:sidekiq'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: sidekiq_config_url,
    namespace: 'qyer:mobile:sidekiq'
  }
end