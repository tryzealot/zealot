class Api::V1::JenkinsController < Api::V1::ApplicationController
  before_action :set_client

  attr_reader :client

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
    status = project_status
    if status[:status] != 'running'
      if @client.job.build(params[:project]).to_i != 201
        return render json: {
          code: 500,
          message: '构建请求失败，请重新尝试'
        }
      end

      project = @client.job.list_details(params[:project])
      number = project['nextBuildNumber']
      url = "#{project['url']}#{number}/"
      code = 201
    else
      url = status[:project]['url']
      number = status[:number]
      code = 200
    end

    render json: {
      code: code,
      number: number,
      url: url
    }
  end


  def status
    render json: project_status
  end

  private

  def project_status
    build_number = if params[:id].to_s.blank?
      @client.job.get_current_build_number(params[:project])
    else
      params[:id].to_s
    end

    build_detail = @client.job.get_build_details(params[:project], build_number)
    build_status =
      if build_detail['result'].to_s.empty?
        'running'
      else
        build_detail['result'].downcase
      end

    {
      number: build_number,
      status: build_status,
      project: build_detail
    }
  end

  def set_client
    @client = JenkinsApi::Client.new(
      server_ip: '172.1.1.227',
      server_port: '8888'
    )
  end
end
