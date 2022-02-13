# frozen_string_literal: true

class Api::VersionController < Api::BaseController
  # GET /version
  def index
    render json: {
      version: Setting.version,
      vcs_ref: Setting.vcs_ref,
      build_date: Setting.build_date
    }
  end
end
