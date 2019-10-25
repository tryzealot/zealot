
class Api::Jenkins::ProjectsController < Api::JenkinsController

  def index
    projects = []
    @client.job.list_all.each do |j|
      projects.push(@client.job.list_details(j))
    end

    render json: projects
  end

  def show
    project = @client.job.list_details(params[:project])
    render json: project
  end
end