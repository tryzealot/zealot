
class Api::Jenkins::StatusController < Api::JenkinsController
  def show
    render json: project_status
  end
end