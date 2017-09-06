class DeepLinksController < ApplicationController
  before_action :set_deep_link, only: [:show, :edit, :update, :destroy]
  before_action :set_categories

  # GET /deep_links
  def index
    @title = 'Deep Links 列表'

    @deep_links = {}
    @categories.each do |name|
      @deep_links[name] = DeepLink.where(category: name)
    end
  end

  # GET /deep_links/1
  def show
    @title = @deep_link.name
  end

  # GET /deep_links/new
  def new
    @title = '新建 Deep Links'
    @deep_link = DeepLink.new
  end

  # GET /deep_links/1/edit
  def edit
    @title = '编辑 Deep Links'
  end

  # POST /deep_links
  def create
    @deep_link = DeepLink.new(deep_link_params)

    if @deep_link.save
      redirect_to @deep_link, notice: 'Deep link was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /deep_links/1
  def update
    if @deep_link.update(deep_link_params)
      redirect_to @deep_link, notice: 'Deep link was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /deep_links/1
  def destroy
    @deep_link.destroy
    redirect_to deep_links_url, notice: 'Deep link was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deep_link
      @deep_link = DeepLink.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def deep_link_params
      params.require(:deep_link).permit(:name, :category, :links)
    end

    def set_categories
      @categories = %w(首页 目的地 论坛 结伴 问答 酒店 折扣 用户 行程 第三方App 其他)
    end
end
