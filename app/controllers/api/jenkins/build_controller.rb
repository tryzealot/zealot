# frozen_string_literal: true

class Api::Jenkins::BuildController < Api::JenkinsController
  before_action :set_project_status

  def create
    return render_running_status if running?
    return render_build_failed if @client.job.build(params[:project]).to_i != 201

    project = @client.job.list_details(params[:project])
    number = project['nextBuildNumber']
    render json: {
      code: :created,
      number: number,
      url: "#{project['url']}#{number}/"
    }
  end

  private

  def render_running_status
    render json: {
      code: 200,
      number: @status[:number],
      url: @status[:project]['url']
    }
  end

  def render_build_failed
    render json: {
      code: 500,
      message: t('api.jenkins.build.failed_request')
    }
  end

  def running?
    @status[:status] == 'running'
  end

  def set_project_status
    @status = project_status
  end
end
