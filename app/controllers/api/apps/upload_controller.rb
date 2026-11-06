# frozen_string_literal: true

class Api::Apps::UploadController < Api::BaseController
  include AppArchived

  before_action :validate_user_token
  before_action :set_parser
  before_action :set_channel

  # Upload an App
  #
  # POST /api/apps/upload
  #
  # @param token         [String]   required  user token
  # @param file          [String]   required  file of app
  # @param channel_key   [String]   optional  channel key of app
  # @param name          [String]   optional  name of app
  # @param password      [String]   optional  password to download app
  # @param release_type  [String]   optional  release type(debug, beta, adhoc, release, enterprise etc)
  # @param source        [String]   optional  upload source(api, cli, jenkins, gitlab-ci etc)
  # @param changelog     [String]   optional  changelog
  # @param branch        [String]   optional  git branch
  # @param git_commit    [String]   optional  git commit
  # @param ci_url        [String]   optional  ci url
  # @return              [String]   json formatted app info
  def create
    result = create_or_update_release

    if result&.success?
      render json: result.release,
             serializer: Api::UploadAppSerializer,
             status: :created
    else
      render json: { error: result&.message }, status: :unprocessable_entity
    end
  end

  private

  def create_or_update_release
    result = nil
    ActiveRecord::Base.transaction do
      result = new_record? ? create_new_app_build : create_build_from_exist_app
      raise ActiveRecord::Rollback unless result&.success?
    end
    result
  end

  def create_new_app_build
    return ReleaseUploadService::Result.failure(:unsupported_file_type, 'Unable to parse file') unless @app_parser

    channel = with_channel and_scheme and_app
    authorize channel.releases.build

    ReleaseUploadService.call(
      channel: channel,
      file: params[:file],
      user: current_user,
      params: release_params.except(:file),
      parser: @app_parser,
      source: params[:source].presence || 'api'
    )
  end

  def create_build_from_exist_app
    authorize @channel.releases.build

    update_channel_if_needed

    ReleaseUploadService.call(
      channel: @channel,
      file: params[:file],
      user: current_user,
      params: release_params.except(:file),
      parser: @app_parser,
      source: params[:source].presence || 'api'
    )
  end

  def new_record?
    @channel.blank?
  end

  def update_channel_if_needed
    return if channel_params.blank?

    @channel.update!(channel_params)
  end

  def with_channel(scheme)
    channel = scheme.channels.find_or_create_by(channel_params) do |c|
      c.name = @app_parser.platform
      c.device_type = @app_parser.platform
    end
    authorize channel
    channel
  end

  def and_scheme(app)
    name = parse_scheme_name
    scheme = app.schemes.find_or_create_by(name: name)
    authorize scheme
    scheme
  end

  def and_app
    permitted = params.permit :name
    permitted[:name] ||= @app_parser.name

    app = App.find_or_create_by permitted
    app.create_owner(current_user)
    authorize app
    app
  end

  def parse_scheme_name
    default_name = t('api.apps.upload.create.adhoc')
    return default_name unless @app_parser.platform == AppInfo::Platform::IOS

    t("api.apps.upload.create.#{@app_parser.release_type.downcase}", default: default_name)
  end

  def release_params
    params.permit(
      :file, :release_type, :source, :branch, :git_commit,
      :ci_url, :changelog, :devices, :custom_fields
    )
  end

  def channel_params
    @channel_params ||= -> {
      obj = {}
      append_present_value_from_params(obj, :slug)
      append_present_value_from_params(obj, :password)
      append_present_value_from_params(obj, :git_url)
      append_present_value_from_params(obj, :download_filename_type)
      obj
    }.call
  end

  def set_parser
    return if params[:channel_key].present?
    return unless params[:file].respond_to?(:path) && File.exist?(params[:file].path)

    @app_parser = AppInfo.parse(params[:file].path)
  rescue AppInfo::UnknownFormatError
    @app_parser = nil
  end

  def set_channel
    return if params[:channel_key].blank?

    @channel = Channel.find_by(key: params[:channel_key])
    raise ActiveRecord::RecordNotFound, t('releases.messages.errors.not_found_app') unless @channel

    raise_if_app_archived!(@channel.app)
  end

  def append_present_value_from_params(data, key)
    return unless (value = params[key])

    if key == :password && value.blank?
      data[key] = nil
      return
    end

    data[key] = value if value.present?
  end
end
