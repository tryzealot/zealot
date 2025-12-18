# frozen_string_literal: true

class Admin::BackgroundJobsController < ApplicationController
  before_action :goodjob_locale

  # GET /admin/background_jobs
  def index
    @locale = current_locale
  end

  private

  def goodjob_locale
    goodjob_i18n ||= ::GoodJob::I18nConfig.new
    @goodjob_locale = if goodjob_i18n.available_locales.include?(current_locale.to_sym)
                current_locale
              else 
                goodjob_i18n.default_locale
              end
  end
end
