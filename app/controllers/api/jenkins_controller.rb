# frozen_string_literal: true

class Api::JenkinsController < ActionController::API
  before_action :set_client

  def project_status
    build_number = build_number
    build_detail = @client.job.get_build_details(params[:project], build_number)
    build_status = build_status(build_detail)

    {
      number: build_number,
      status: build_status,
      project: build_detail
    }
  end

  private

  def build_number
    params[:id].presence || @client.job.get_current_build_number(params[:project])
  end

  def build_status(build_detail)
    build_detail['result']&.downcase || 'running'
  end

  def set_client
    @client = JenkinsApi::Client.new(server_url: ENV['JENKINS_URL'])
  end
end
