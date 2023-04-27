# frozen_string_literal: true

class Api::Apps::VersionExistController < Api::BaseController
  before_action :validate_channel_key

  # GET /api/apps/version_exist
  def show
    determine_params!

    where_params = channel_params.merge(channel_id: @channel.id)
    raise ActiveRecord::RecordNotFound, t('api.apps.version_exist.show.not_found') unless Release.exists?(where_params)

    render json: Release.find_by(where_params)
  end

  private

  def determine_params!
    return if (channel_params.key?(:bundle_id) && channel_params.key?(:git_commit)) ||
              (channel_params.key?(:bundle_id) && channel_params.key?(:release_version) &&
              channel_params.key?(:build_version))

    raise ActionController::ParameterMissing, t('api.apps.version_exist.show.missing_params')
  end

  def channel_params
    params.permit(:bundle_id, :release_version, :build_version, :git_commit)
  end
end
