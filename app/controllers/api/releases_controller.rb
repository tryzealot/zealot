# frozen_string_literal: true

class Api::ReleasesController < Api::BaseController
  before_action :validate_user_token
  before_action :set_release

  # UPDATE /releases/:id
  def update
    @release.update!(release_params)
    render json: @release
  end

  # DELETE /releases/:id
  def destroy
    @release.destroy
    render json: { mesage: 'OK' }
  end

  protected

  def set_release
    @release = Release.find(params[:id])
  end

  def release_params
    params.permit(
      :release_version, :build_version, :release_type, :source, :branch, :git_commit,
      :ci_url, :custom_fields, :changelog
    )
  end
end
