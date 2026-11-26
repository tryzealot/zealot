# frozen_string_literal: true

class AppsController < ApplicationController
  include AppArchived
  include AppListScope

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_entity_response

  before_action :set_app, only: %i[show edit update destroy new_owner update_owner]
  before_action :set_selected_schemes_and_channels, only: %i[edit]
  before_action :process_scheme_and_channel, only: %i[create]
  before_action :set_owner, only: %i[new_owner update_owner]

  def index
    @title = t('.title')
    @scope = resolved_scope
    @sort = resolved_sort

    base_scope = app_list_base_scope
    searched_scope = params[:search].present? ? base_scope.search_by_name(params[:search]) : base_scope
    @apps = searched_scope.by_scope(@scope).sort_by_name(@sort)
    @scope_counts = scope_counts_for(base_scope)
    authorize @apps if @apps.present?
  end

  def show
    @title = @app.name
    set_show_activity
  end

  def new
    @title = t('.title')
    @app = App.new
    @app.organization_id = current_org.id if @app.respond_to?(:organization_id=) && current_org.respond_to?(:persisted?) && current_org.persisted?
    authorize @app

    @app.schemes.build
  end

  def edit
    raise_if_app_archived!(@app)

    @title = t('.title')
  end

  def create
    @app = App.new(app_params)
    @app.organization_id = current_org.id if @app.respond_to?(:organization_id=) && current_org.respond_to?(:persisted?) && current_org.persisted?
    authorize @app
    return render :new, status: :unprocessable_entity unless @app.save

    create_owner
    create_schemes_and_channels

    flash.now[:notice] = t('activerecord.success.create', key: "#{@app.name} #{t('apps.title')}")
    respond_to do |format|
      format.html { redirect_to apps_path }
      format.turbo_stream
    end
  end

  def update
    raise_if_app_archived!(@app)

    @app.update(app_params)
    respond_to do |format|
      format.html { redirect_to apps_path }
      format.turbo_stream
    end
  end

  def destroy
    @app.destroy
    destroy_app_data

    respond_to do |format|
      format.any { redirect_to apps_path }
    end
  end

  def new_owner
    raise_if_app_archived!(@app)
    authorize @app, :new_owner?

    @title = t('.title')
  end

  def update_owner
    raise_if_app_archived!(@app)
    authorize @app, :update_owner?

    @title = t('apps.new_owner.title')
    @previous_user = @collaborator&.user
    user_id = owner_params[:user_id]
    if @previous_user&.id == user_id.to_i
      notice = t('activerecord.errors.messages.same_value', key: t('apps.new_owner.title'))
      return redirect_to @collaborator.app, notice: notice, status: :see_other
    end

    new_owner = User.find(user_id)
    Collaborator.transaction do
      @collaborator&.update!(owner: false)
      new_collab = @app.collaborators.find_or_initialize_by(user: new_owner)
      new_collab.role = :admin
      new_collab.owner = true
      new_collab.save!
    end

    notice = t('activerecord.success.update', key: t('apps.new_owner.title'))
    flash.now[:notice] = notice
    respond_to do |format|
      format.html { redirect_to @app }
      format.turbo_stream
    end
  rescue ActiveRecord::RecordInvalid
    render :new_owner, status: :unprocessable_entity
  end

  private

  def set_show_activity
    @schemes = @app.schemes.includes(:channels)
    @channels = Channel.where(id: @app.channel_ids).includes(:scheme)

    scope = Release.where(channel_id: @app.channel_ids)
    if params[:scheme_id].present? && (scheme = @app.schemes.find_by(id: params[:scheme_id]))
      scope = scope.where(channel_id: scheme.channels.select(:id))
    elsif params[:channel_id].present? && (channel = @channels.find_by(id: params[:channel_id]))
      scope = scope.where(channel_id: channel.id)
    end

    @releases = scope.page(params.fetch(:page, 1)).per(params.fetch(:per_page, Setting.per_page)).order(id: :desc)
  end

  def destroy_app_data
    require 'fileutils'

    app_binary_path = Rails.root.join('public', 'uploads', 'apps', "a#{@app.id}")
    FileUtils.rm_rf(app_binary_path) if Dir.exist?(app_binary_path)
  end

  def create_owner
    return if current_user.blank? || current_user.guest?

    @app.create_owner(current_user)
  end

  def create_schemes_and_channels
    @schemes.each do |scheme_name|
      scheme = @app.schemes.create(name: scheme_name)
      next if @channels.empty?

      @channels.each do |channel_name|
        scheme.channels.create name: channel_name, device_type: channel_name.downcase.to_sym
      end
    end
  end

  def set_selected_schemes_and_channels
    @schemes = []
    @channels = []
    @app.schemes.each do |scheme|
      @schemes << scheme.name

      channels = scheme.channels.pluck(:name)
      channels.each do |channel_name|
        @channels << channel_name unless @channels.include?(channel_name)
      end
    end
  end

  def process_scheme_and_channel
    @schemes = app_params.delete(:scheme_attributes)[:name].reject(&:empty?)
    @channels = app_params.delete(:channel_attributes)[:name].reject(&:empty?)
  end

  def set_app
    @app = org_scope(App).find(params[:id])
    authorize @app
  end

  def app_params
    @app_params ||= params.require(:app)
                          .permit(
                            :name,
                            scheme_attributes: { name: [] },
                            channel_attributes: { name: [] },
                          )
  end

  def set_owner
    @collaborator = @app.collaborators.find_by(owner: true)
  end

  def owner_params
    params.require(:collaborator).permit(:user_id)
  end

  def render_not_found_entity_response(e)
    return not_found(e) unless e.model == 'App'

    redirect_to apps_path, alert: t('apps.messages.failture.not_found_app', id: e.id)
  end
end
