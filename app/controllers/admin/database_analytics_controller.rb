# frozen_string_literal: true

class Admin::DatabaseAnalyticsController < ApplicationController
  def index
    @title = t('menu.database_analytics')
  end
end
