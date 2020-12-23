# frozen_string_literal: true

class Api::Apps::VersionExistController < Api::BaseController
  before_action :validate_channel_key

  # GET /api/apps/version_exist
  def show
    determine_params!

    where_params = channel_params.merge(channel_id: @channel.id)
    raise ActiveRecord::RecordNotFound, '应用版本不存在' unless Release.exists?(where_params)

    render json: Release.find_by(where_params)
  end

  private

  def determine_params!
    return if (channel_params.key?(:bundle_id) && channel_params.key?(:git_commit)) ||
              (channel_params.key?(:bundle_id) && channel_params.key?(:release_version) &&
              channel_params.key?(:build_version))

    raise ActionController::ParameterMissing,
          '参数缺失，请使用 bundle_id, release_version, build_version 或 bundle_id, git_commit 组合参数'
  end

  def channel_params
    params.permit(:bundle_id, :release_version, :build_version, :git_commit)
  end
end
