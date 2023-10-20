RailsSettings.configure do
  self.cache_storage = ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp', 'cache', 'rails-settings'))
end
