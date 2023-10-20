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
  end

  def system_analytics
    general_widgets
    admin_panels if current_user&.admin?
  end

  def general_widgets
    @analytics = {
      apps: App.count,
      releases: Release.count,
      debug_files: DebugFile.count,
      teardowns: Metadatum.count,
    }
  end

  def admin_panels
    @analytics.merge!({
      users: User.count,
      webhooks: WebHook.count,
      jobs: sidekiq_stats,
      disk: disk_usage,
    })
  end

  def sidekiq_stats
    # stat = Sidekiq::Stats.new
    # "#{stat.workers_size} / #{stat.processed}"
    ""
  end

  def disk_usage
    disk = Sys::Filesystem.stat(Rails.root)
    percent = (disk.bytes_used.to_f / disk.bytes_total.to_f * 100.0)
    ActiveSupport::NumberHelper.number_to_percentage(percent, precision: 0)
  end
end
