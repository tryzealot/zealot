class JspatchesController < ApplicationController
  before_action :set_jspatch, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, if: :js_request?

  # GET /jspatches
  # GET /jspatches.json
  def index
    @title = '热补丁列表'
    @jspatches = Jspatch.all
  end

  # GET /jspatches/1
  # GET /jspatches/1.json
  def show
  end

  # GET /jspatches/new
  def new
    @title = "新建 iOS 应用补丁"
    @jspatch = Jspatch.new
    @apps = App.all
  end

  # GET /jspatches/1/edit
  def edit
    @apps = App.all
  end

  # POST /jspatches
  # POST /jspatches.json
  def create
    @jspatch = Jspatch.new(jspatch_params)

    respond_to do |format|
      if @jspatch.save
        format.html { redirect_to @jspatch, notice: 'Jspatch was successfully created.' }
        format.json { render :show, status: :created, location: @jspatch }
      else
        format.html { render :new }
        format.json { render json: @jspatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jspatches/1
  # PATCH/PUT /jspatches/1.json
  def update
    respond_to do |format|
      if @jspatch.update(jspatch_params)
        format.html { redirect_to @jspatch, notice: 'Jspatch was successfully updated.' }
        format.json { render :show, status: :ok, location: @jspatch }
      else
        format.html { render :edit }
        format.json { render json: @jspatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jspatches/1
  # DELETE /jspatches/1.json
  def destroy
    @jspatch.destroy
    respond_to do |format|
      format.html { redirect_to jspatches_url, notice: 'Jspatch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected

  def js_request?
    request.format.js?
  end

  private

  def set_jspatch
    @jspatch = Jspatch.find(params[:id])
  end

  def jspatch_params
    params.require(:jspatch).permit(:app_id, :title, :app_version, :script)
  end
end
