class VisitorsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @title = '我的控制台'
  end
end
