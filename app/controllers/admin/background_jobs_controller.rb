# frozen_string_literal: true

class Admin::BackgroundJobsController < ApplicationController
  # GET /admin/background_jobs
  def index
    @title = t('background_jobs.title')
  end
end
