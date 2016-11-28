class VisitorsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @title = '我的控制台'
  end

  def test
  end
end
