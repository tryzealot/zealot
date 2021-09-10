# frozen_string_literal: true

class Admin::PageAnalyticsController < ApplicationController
  def index
    @title = t('page_analytics.title')
  end
end
