# frozen_string_literal: true

class Admin::BackgroundJobsController < ApplicationController
  # GET /admin/background_jobs
  def index
    @title = '后台任务'
  end
end
