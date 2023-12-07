# frozen_string_literal: true

class TeardownsController < ApplicationController
  before_action :authenticate_user!, except: %[show]
  before_action :set_metadata, only: %i[show destroy]

  def index
    @title = t('.title')
    @metadata = Metadatum.page(params.fetch(:page, 1))
                         .per(params.fetch(:per_page, Setting.per_page))
                         .order(id: :desc)
  end

  def show
    authorize @metadata

    # Windows 应用会存在名称，版本号全无的情况
    name = @metadata.name || @metadata.id
    version = @metadata.release_version
    version += " (#{@metadata.build_version})" if @metadata.build_version.present?

    @title = t('.title', name: "#{name} #{version}")
  end

  def new
    @title = t('.title')
    @metadata = Metadatum.new
    authorize @metadata
  end

  def create
    @title = t('.title')
    parse_app
  rescue => e
    logger.error "Teardown error: #{e}"
    flash[:error] = case e
      when AppInfo::NotFoundError, ActiveRecord::RecordNotFound
        t('teardowns.messages.errors.not_found_file', message: e.message)
      when ActionController::RoutingError
        e.message
      when AppInfo::UnknownFormatError
        t('teardowns.messages.errors.not_support_file_type')
      when NoMethodError
        t('teardowns.messages.errors.failed_get_metadata')
      else
        Sentry.capture_exception e
        t('teardowns.messages.errors.unknown_parse', class: e.class, message: e.message)
      end

    render :new, status: :unprocessable_entity
  end

  def destroy
    authorize @metadata
    @metadata.destroy

    redirect_to teardowns_path, notice: t('activerecord.success.destroy', key: "#{t('teardowns.title')}")
  end

  private

  def set_metadata
    @metadata = Metadatum.find(params[:id])
  end

  def parse_app
    unless file = params[:file]
      raise ActionController::RoutingError, t('teardowns.messages.errors.choose_supported_file_type')
    end

    metadata = TeardownService.new(file).call
    metadata.update_attribute(:user_id, current_user&.id) if current_user.present?

    redirect_to teardown_path(metadata)
  end
end
