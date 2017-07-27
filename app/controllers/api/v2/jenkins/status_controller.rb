
class Api::V2::Jenkins::StatusController < Api::V2::JenkinsController
  def show
    render json: project_status
  end
end