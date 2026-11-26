# frozen_string_literal: true

class DashboardsController < ApplicationController
  include AppListScope

  def index
    @title = t('dashboard.title')

    system_analytics
    recently_upload
  end

  private

  def recently_upload
    base = Release.joins(channel: :scheme).where(schemes: { app_id: app_list_base_scope.select(:id) })

    @releases = base.page(params.fetch(:page, 1))
                    .per(params.fetch(:per_page, Setting.per_page))
                    .order(id: :desc)
  end

  def system_analytics
    general_widgets
    admin_panels
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
    return unless current_user&.admin?

    user_count = if current_org.respond_to?(:users) && current_org.respond_to?(:persisted?) && current_org.persisted?
      current_org.users.count
    else
      User.count
    end

    @analytics.merge!({
      users: user_count,
      webhooks: WebHook.count,
      jobs: job_stats,
      disk: disk_usage,
    })
  end

  def job_stats
    filters = GoodJob::JobsFilter.new(params)
    states = filters.states
    states['running']
  end

  def disk_usage
    disk = Sys::Filesystem.stat(Rails.root)
    percent = (disk.bytes_used.to_f / disk.bytes_total.to_f * 100.0)
    ActiveSupport::NumberHelper.number_to_percentage(percent, precision: 0)
  end

  def user_apps
    app_list_base_scope.active.count
  end

  def user_teardowns
    return org_scope(Metadatum).count if Setting.guest_mode || !!current_user&.admin?
    return 0 unless current_user.respond_to?(:metadatum) && current_user&.metadatum

    org_scope(current_user.metadatum).count
  end

  def user_debug_files
    DebugFile.where(app_id: app_list_base_scope.select(:id)).count
  end

  def app_uploads
    Release.joins(channel: :scheme).where(schemes: { app_id: app_list_base_scope.select(:id) }).count
  end
end
