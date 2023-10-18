# # frozen_string_literal: true

# def add_or_delete_schedule(remove, cron_jobs, key)
#   if remove
#     Sidekiq.remove_schedule(key.to_s)
#   else
#     cron_jobs[key] = SCHEDULED_JOBS[key]
#   end
# end

# SCHEDULED_JOBS = {
#   sync_apple_devices: {
#     cron: '0 0 * * *',
#     class: 'SyncAppleDevicesJob',
#     queue: 'schedule',
#     description: 'Syncing devices for all Apple Developers on each 0AM',
#   },
#   clean_old_releases: {
#     cron: '0 6 * * *',
#     class: 'CleanOldReleasesJob',
#     queue: 'schedule',
#     description: 'Clean old versions on each 6AM',
#   },
#   reset_for_demo_mode: {
#     cron: '0 0 * * *',
#     class: 'ResetForDemoModeJob',
#     queue: 'schedule',
#     description: 'Reset demo data everyday'
#   }
# }

# Rails.application.reloader.to_prepare do
#   if Sidekiq.server?
#     cron_jobs = {
#       sync_apple_devices: SCHEDULED_JOBS[:sync_apple_devices]
#     }

#     add_or_delete_schedule(Setting.keep_uploads, cron_jobs, :clean_old_releases)
#     add_or_delete_schedule(!Setting.demo_mode, cron_jobs, :reset_for_demo_mode)

#     Backup.enabled_jobs.each do |backup|
#       cron_jobs[backup.schedule_key] = backup.schedule_job
#     end

#     Sidekiq.schedule = cron_jobs
#     SidekiqScheduler::Scheduler.instance.reload_schedule!
#   end
# end
