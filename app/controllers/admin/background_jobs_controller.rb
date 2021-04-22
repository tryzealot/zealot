# frozen_string_literal: true

class Admin::BackgroundJobsController < ApplicationController
  # GET /admin/background_jobs
  def index
    @title = t('menu.background_jobs')
  end
end
