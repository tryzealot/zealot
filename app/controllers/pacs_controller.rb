class PacsController < ApplicationController
  before_action :set_pac, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, if: :js_request?

  def index
    @pacs = Pac.all
  end

  def show
  end

  def new
    @title = "新建 pac 文件"
    @pac = Pac.new
  end

  def create
    @pac = Pac.new(pac_params)

    respond_to do |format|
      if @pac.save
        format.html { redirect_to @pac, notice: 'pac was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  protected
    def js_request?
      request.format.js?
    end

  private
    def set_pac
      @pac = Pac.find(params[:id])
    end

    def pac_params
      params.require(:pac).permit(:name, :host, :port, :content)
    end
end
