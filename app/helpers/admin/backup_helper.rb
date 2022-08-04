# frozen_string_literal: true

module Admin
  module BackupHelper
    def schedule_to_human(schedule)
      parse_schedule(schedule).to_cron_s
    end

    def next_schedule_to_human(schedule)
      parse_schedule(schedule).next_time
    end

    def explan_scopes(backup)
      [].tap do |obj|
        obj << t('admin.backups.index.database') if backup.enabled_database?
        if count = backup.enabled_channels.count
          obj << t('admin.backups.index.channel', count: count)
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