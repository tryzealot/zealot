class PacsController < ApplicationController
  before_action :authenticate_user!, only: [ :index, :new, :create, :edit, :update, :destroy]
  before_action :set_pac, only: [:show, :edit, :update, :destroy]

  # GET /pacs
  def index
    @title = '自动代理列表'
    @pacs = Pac.all
  end

  # GET /pacs/1
  # GET /pacs/1.pac
  def show
    respond_to do |format|
      format.pac { render :show, status: :ok, location: @pac }
      format.html { render :show, status: :ok, location: @pac }
    end
  end

  # GET /pacs/new
  def new
    @title = '新建自动代理'
    @pac = Pac.new
  end

  def edit
    @title = '编辑自动代理'
  end

  # POST /pacs/create
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

  # PATCH/PUT /pacs/1
  # PATCH/PUT /pacs/1.pac
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

  # DELETE /pacs/1
  # DELETE /pacs/1.pac
  def destroy
    @pac.destroy
    respond_to do |format|
      format.html { redirect_to pacs_url, notice: 'pac was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected

  def js_request?
    request.format.js?
  end

  def set_pac
    @pac = Pac.find(params[:id])
  end

  def pac_params
    params.require(:pac).permit(:title, :host, :port, :is_enabled, :script)
  end
end
