# frozen_string_literal: true

class Api::Apps::ExistController < Api::BaseController
  # before_action :validate_user_token
  before_action :validate_channel_key

  def show
    determine_params!

    where_params = channel_params.merge(channel_id: @channel.id)
    is_existed = Release.exists?(where_params)

    body = { exist: is_existed }
    body[:release] = Release.find_by(where_params) if is_existed

    render json: body
  end

  private

  def determine_params!
    return if (channel_params.key?(:buidle_id) && channel_params.key?(:git_commit)) ||
              (channel_params.key?(:buidle_id) && channel_params.key?(:release_version) &&
              channel_params.key?(:build_version))

    raise ActionController::ParameterMissing,
          'Choose bundle_id, release_version, build_version or bundleid_id, git_commit'
  end

  def channel_params
    params.permit(:buidle_id, :release_version, :build_version, :git_commit)
  end
end
