# frozen_string_literal: true

class Admin::DatabaseAnalyticsController < ApplicationController
  def index
    @title = t('database_analytics.title')
  end
end
