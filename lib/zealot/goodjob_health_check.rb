# frozen_string_literal: true

class Zealot::GoodjobHealthCheck
  def self.check
    unless defined?(::GoodJob)
      raise "Wrong configuration. Missing 'good_job' gem"
    end

    count = GoodJob::Process.active.count
    count > 0 ? '' : "GoodJob process count is #{count} instead of > 0"
  rescue Exception => e
    "[goojob - #{e.message}] "
  end
end