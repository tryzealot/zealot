class PacsController < ApplicationController
  before_action :set_pac, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, if: :js_request?

  def index
    @pacs = Pac.all
  end

  def show
    respond_to do |format|
      format.pac { render :show, status: :ok, location: @pac }
      format.html { render :show, status: :ok, location: @pac }
    end
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

  # PATCH/PUT /jspatches/1
  # PATCH/PUT /jspatches/1.json
  def update
    respond_to do |format|
      if @pac.update(pac_params)
        format.html { redirect_to @pac, notice: 'pac was successfully updated.' }
        format.json { render :show, status: :ok, location: @pac }
      else
        format.html { render :edit }
        format.json { render json: @pac.errors, status: :unprocessable_entity }
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
      params.require(:pac).permit(:title, :host, :port, :is_enabled, :script)
    end
end
