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

    private

    def parse_schedule(value)
      # dependency from sidekiq-schedule
      Fugit.parse(value)
    end
  end
end