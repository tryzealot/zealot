class VisitorsController < ApplicationController
  before_filter :authenticate_user!, only: [:index]

  def index
    @title = '我的控制台'
  end

  def test
  end
end
