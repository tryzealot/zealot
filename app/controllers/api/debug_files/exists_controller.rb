# frozen_string_literal: true

class Api::DebugFiles::ExistsController < Api::BaseController
  before_action :validate_channel_key, only: :version

  # GET /api/debug_files/exist/version
  def version
    determine_params!

    where_params = channel_params.merge(
      app_id: @channel.app.id,
      device_type: @channel.device_type
    )

    unless DebugFile.exists?(where_params)
      raise ActiveRecord::RecordNotFound, t('api.debug_files.download.default.not_found')
    end

    render json: DebugFile.find_by(where_params)
  end

  # GET /api/debug_files/exist/binary
  def binary
    checksum = params[:checksum]
    raise ActionController::ParameterMissing, 'checksum' if checksum.blank?

    debug_file = DebugFile.find_by(checksum: checksum)
    raise ActiveRecord::RecordNotFound, t('api.debug_files.download.default.not_found') unless debug_file

    render json: debug_file
  end

  # GET /api/debug_files/exist/uuid
  def uuid
    uuid = params[:uuid]
    raise ActionController::ParameterMissing, 'uuid' if uuid.blank?

    metadata = DebugFileMetadatum.find_by(uuid: uuid)
    raise ActiveRecord::RecordNotFound, t('api.debug_files.download.default.not_found') unless metadata

    render json: metadata.debug_file
  end

  private

  def determine_params!
    return if (channel_params.key?(:release_version) && channel_params.key?(:build_version))

    raise ActionController::ParameterMissing, 'release_version, build_version'
  end

  def channel_params
    params.permit(:app_id, :device_type, :release_version, :build_version)
  end
end
