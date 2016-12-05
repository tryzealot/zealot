class Api::V1::PatchController < ApplicationController
  # skip_before_action :verify_authenticity_token, if: :js_request?


  # GET /api/patch/app/KujdgCa
  def index
    @app = App.find_by(key: params[:key], identifier: params[:id])
    @jspatch = Jspatch.find_by(app: @app, app_version: [params[:sv], params[:bv]])

    if @jspatch
      render "jspatches/show", status: 200
    else
      render js: '// script not found.', status: 404
    end
  end

  protected
    def js_request?
      request.format.js?
    end
end
