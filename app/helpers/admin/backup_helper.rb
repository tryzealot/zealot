# frozen_string_literal: true

module Admin
  module BackupHelper
    def schedule_to_human(schedule)
      parse_schedule(schedule).to_cron_s
    end

    def next_schedule_to_human(schedule)
      parse_schedule(schedule).next_time
    end

    def explan_scopes(scopes)
      scopes.each_with_object([]) do |scope, obj|
        case scope.key
        when BackupScope::DATABASE
          obj << t('admin.backups.index.database')
        when BackupScope::CHANNEL
          obj << t('admin.backups.index.channel', count: scope.channels.size)
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