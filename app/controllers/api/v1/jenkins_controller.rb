class Api::V1::JenkinsController < Api::ApplicationController
  def projects
    @client = JenkinsApi::Client.new(
      server_ip: '172.1.1.227',
      server_port: '8888'
    )

    projects = []
    @client.job.list_all.each do |j|
      projects.push(@client.job.list_details(j))
    end

    render json: projects
  end

  def project
    @client = JenkinsApi::Client.new(
      server_ip: '172.1.1.227',
      server_port: '8888'
    )

    project = @client.job.list_details(params[:project])

    render json: project
  end

  def build
    @client = JenkinsApi::Client.new(
      server_ip: '172.1.1.227',
      server_port: '8888'
    )

    status = @client.job.build(params[:project])

    render json: {
      status: status
    }
  end

  def abort
    @client = JenkinsApi::Client.new(
      server_ip: '172.1.1.227',
      server_port: '8888'
    )

    status = @client.job.stop_build(params[:project], params[:id])

    render json: {
      status: status
    }
  end

  def status
    @client = JenkinsApi::Client.new(
      server_ip: '172.1.1.227',
      server_port: '8888'
    )

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
end
