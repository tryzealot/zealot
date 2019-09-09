class DsymsController < ApplicationController
  before_action :set_dsym, only: [:show, :edit, :update, :destroy]
  before_action :set_app_list, only: [:new, :create]

  def index
    @title = 'dSYM 列表'
    @dsyms = Dsym.all.order(id: :desc)
  end

  def new
    @title = '上传 dSYM 文件'
    @dsym = Dsym.new
  end

  def create
    @title = '上传 dSYM 文件'
    @dsym = Dsym.new(dsym_params)

    if @dsym.save
      redirect_to dsyms_url, notice: 'dSYM 上传成功'
    else
      render :new
    end
  end

  def destroy
    @dsym.destroy
    redirect_to dsyms_url, notice: 'dSYM 删除成功'
  end

  private

  def set_dsym
    @dsym = Dsym.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def dsym_params
    params.require(:dsym).permit(
      :app_id, :release_version, :build_version, :file
    )
  end

  def set_app_list
    @apps = App.all
  end
end
