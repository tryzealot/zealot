# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user! unless Setting.guest_mode

  def index
    @title = t('dashboard.title')

    system_analytics
    recently_upload
  end

  private

  def recently_upload
    @releases = Release.page(params.fetch(:page, 1))
                       .per(params.fetch(:per_page, Setting.per_page))
                       .order(id: :desc)
    return if admin_user_or_guest_mode?

    channel_ids = current_user.apps.map { |app| app.channel_ids }
    @releases = @releases.where(channel_id: channel_ids)
  end

  def system_analytics
    general_widgets
    admin_panels if current_user&.admin?
  end

  def general_widgets
    @analytics = {
      apps: user_apps,
      debug_files: user_debug_files,
      teardowns: user_teardowns,
      releases: app_uploads,
    }
  end

  def admin_panels
    @analytics.merge!({
      users: User.count,
      webhooks: WebHook.count,
      jobs: job_stats,
      disk: disk_usage,
    })
  end

  def job_stats
    filters = GoodJob::JobsFilter.new(params)
    states = filters.states
    "#{states["running"]} / #{states.values.sum}"
  end

  def disk_usage
    disk = Sys::Filesystem.stat(Rails.root)
    percent = (disk.bytes_used.to_f / disk.bytes_total.to_f * 100.0)
    ActiveSupport::NumberHelper.number_to_percentage(percent, precision: 0)
  end

  def user_apps
    return App.count if Setting.guest_mode || current_user.admin?

    current_user.apps.count
  end

  def user_teardowns
    return Metadatum.count if Setting.guest_mode || current_user.admin?

    current_user.metadatum.count
  end

  def user_debug_files
    return DebugFile.count if Setting.guest_mode || current_user.admin?

    current_user.apps.sum {|app| app.total_debug_files }
  end

  def app_uploads
    return Release.count if Setting.guest_mode || current_user.admin?

    current_user.apps.sum {|app| app.total_releases }
  end
end
