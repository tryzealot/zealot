
class Api::V2::JenkinsController < ActionController::API
  before_action :set_client

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