# frozen_string_literal: true

class Admin::PageAnalyticsController < ApplicationController
  def index
    @title = t('menu.page_analytics')
  end
end
