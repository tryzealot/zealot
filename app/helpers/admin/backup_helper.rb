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
        tag.div(tag.span('Processing', class: 'visually-hidden'), class: 'spinner-grow spinner-grow-sm text-warning me-2')
      when :discarded, :retried
        tag.i(class: 'fa-solid fa-exclamation-circle text-danger me-2')
      when :succeeded
        tag.i(class: 'fa-solid fa-check-circle text-success me-2')
      end
    end

    def job_stage(stage)
      I18n.t(stage, scope: 'admin.backups.show.steps', default: "")
    end

    def job_progress(status)
      value = if status[:progress] && status[:total]
                status[:progress] / status[:total].to_f * 100
              else
                0
              end

      number_to_percentage(value, precision: 0)
    end

    private

    def parse_schedule(value)
      Fugit.parse(value)
    end
  end
end
