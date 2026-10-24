# frozen_string_literal: true

class TeardownsController < ApplicationController
  before_action :authenticate_user!, except: %[show] unless Setting.guest_mode
  before_action :set_app
  before_action :set_metadata, only: %i[show destroy]

  def index
    @title = t('.title')
    page = params.fetch(:page, 1)
    per_page = params.fetch(:per_page, Setting.per_page)
    @metadata = metadata_scope.page(page).per(per_page).order(id: :desc)

    authorize @metadata if @app.present?
  end

  def show
    authorize @metadata

    # Workground for windows app: name or version is blank
    name = @metadata.name || @metadata.id
    version = @metadata.release_version
    version += " (#{@metadata.build_version})" if @metadata.build_version.present?

    @title = t('.title', name: name)
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
    flash.now[:alert] = case e
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

    redirect_to teardowns_index_path_for, notice: t('activerecord.success.destroy', key: "#{t('teardowns.title')}")
  end

  private

  def set_app
    return if params[:app_id].blank?

    @app = App.find(params[:app_id])
  end

  # Everything the visitor may see: the whole list for managers and guests,
  # their own uploads and the uploads of their apps otherwise.
  def metadata_scope
    scope = @app ? app_metadata : Metadatum.all
    return scope if manage_user_or_guest_mode?

    scope.where(user_id: current_user.id).or(scope.where(release_id: my_release_ids))
  end

  # What belongs to the app: uploaded inside the app or parsed from a release
  # of one of its channels.
  def app_metadata
    Metadatum.where(app_id: @app.id)
      .or(Metadatum.where(release_id: Release.where(channel_id: @app.channel_ids)))
  end

  def my_release_ids
    Release.where(channel_id: current_user.apps.flat_map(&:channel_ids))
  end

  def set_metadata
    @metadata = Metadatum.find(params[:id])
  end

  def parse_app
    unless file = teardown_params[:file]
      raise ActionController::RoutingError, t('teardowns.messages.errors.choose_supported_file_type')
    end

    metadata = TeardownService.new(file).call
    metadata.update_attribute(:user_id, current_user&.id) if current_user.present?
    metadata.update_attribute(:app_id, @app.id) if @app

    redirect_to teardown_path_for(metadata)
  end

  def teardown_params
    params.require(:teardown).permit(:file)
  end

  def teardowns_index_path_for
    @app ? app_teardowns_path(@app) : teardowns_path
  end

  def teardown_path_for(metadata)
    @app ? app_teardown_path(@app, metadata) : teardown_path(metadata)
  end
end
