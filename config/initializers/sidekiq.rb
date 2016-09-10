sidekiq_config_url = ENV['JOB_WORKER_URL']


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