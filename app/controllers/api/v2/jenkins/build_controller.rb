
class Api::V2::Jenkins::BuildController < Api::V2::JenkinsController

  def create
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
end