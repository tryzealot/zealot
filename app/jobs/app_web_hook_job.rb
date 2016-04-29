class AppWebHookJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    
  end
end
