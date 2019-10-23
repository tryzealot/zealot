
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
    if params[:id].to_s.blank?
      @client.job.get_current_build_number(params[:project])
    else
      params[:id].to_s
    end
  end

  def build_status(build_detail)
    if build_detail['result'].to_s.empty?
      'running'
    else
      build_detail['result'].downcase
    end
  end

  def set_client
    @client = JenkinsApi::Client.new(server_url: ENV['JENKINS_URL'])
  end
end
