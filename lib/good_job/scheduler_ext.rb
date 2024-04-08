# frozen_string_literal: true

module GoodJob
  class SchedulerExt
    attr_reader :cron

    def initialize
      @cron = GoodJob.configuration.options[:cron]
    end

    def key?(key)
      @cron.key?(key.to_sym)
    end

    def delete(key)
      @cron.delete(key.to_sym)
    end

    def add(key, entry, force: true)
      has_cron = key?(key)
      raise "Scheduler has existed: #{key}" if has_cron && !force
      return @cron[key.to_sym] if has_cron && !force

      @cron[key.to_sym] = entry
    end
  end
end
