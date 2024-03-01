# frozen_string_literal: true

module Admin
  module BackupHelper
    def all_apps
      App.all_names
    end

    def schedule_to_human(schedule)
      parse_schedule(schedule).to_cron_s
    end

    def next_schedule_to_human(schedule)
      parse_schedule(schedule).next_time
    end

    def explan_scopes(backup)
      [].tap do |obj|
        obj << t('admin.backups.index.database') if backup.enabled_database?
        if count = backup.enabled_apps.count
          obj << t('admin.backups.index.app', count: count)
        end
      end.join(' | ')
    end

    def job_icon(status)
      case status
      when :scheduled, :running
        tag.div(tag.span('Processing', class: 'sr-only'), class: 'spinner-grow spinner-grow-sm text-warning mr-2')
      when :discarded, :retried
        tag.i(class: 'fas fa-exclamation-circle text-danger mr-2')
      when :succeeded
        tag.i(class: 'fas fa-check-circle text-success mr-2')
      end
    end

    def job_progress(status)
      number_to_percentage((status[:progress] / status[:total].to_f * 100), precision: 0)
    end

    private

    def parse_schedule(value)
      # dependency from sidekiq-schedule
      Fugit.parse(value)
    end
  end
end
