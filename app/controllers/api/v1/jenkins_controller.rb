class Api::V1::JenkinsController < Api::ApplicationController
  before_action :set_client

  def client
    @client
  end

  def projects
    projects = []
    @client.job.list_all.each do |j|
      projects.push(@client.job.list_details(j))
    end

    render json: projects
  end

  def project
    project = @client.job.list_details(params[:project])

    render json: project
  end

  def build
    status = @client.job.build(params[:project])

    render json: {
      status: status,
      project: @client.job.list_details(params[:project])
    }
  end

  def abort
    status = @client.job.stop_build(params[:project], params[:id])

    render json: {
      status: status
    }
  end

  def status
    build_number = params[:id]
    if params[:id].to_s.empty?
      build_number = @client.job.get_current_build_number(params[:project])
      build_status = @client.job.get_current_build_status(params[:project])
    end

    build_detail = @client.job.get_build_details(params[:project], build_number)

    if build_detail['result'].to_s.empty?
      build_status = 'running'
    else
      build_status = build_detail['result'].downcase
    end

    render json: {
      number: build_number,
      status: build_status,
      entry: build_detail
    }
  end

  private
    def set_client
      @client = JenkinsApi::Client.new(
        server_ip: '172.1.1.227',
        server_port: '8888'
      )
    end
end
