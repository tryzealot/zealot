# frozen_string_literal: true

class Zealot::GoodjobHealthCheck
  extend BaseHealthCheck

  def self.check
    Rails.logger.info '[GoodJob Health Check]'
    unless defined?(::GoodJob)
      raise "Wrong configuration. Missing 'good_job' gem"
    end

    Rails.logger.info '[GoodJob Health Check] - checking process count'
    count = GoodJob::Process.active.size
    count > 0 ? '' : "GoodJob process count is #{count} instead of > 0"
  rescue Exception => e
    create_error 'background_job', e.message
  end
end
