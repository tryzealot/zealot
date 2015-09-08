##
# 仅仅用于 iOS DSYM 文件保存和下载
##
class IosController < ApplicationController
  load_and_authorize_resource class: Ios

  before_filter :authenticate_user!

  def index
    @ioses = Ios.order('created_at DESC').all
  end

  def destroy
    ios = Ios.find(params[:id])
    dsym_file = "public/uploads/ipa/#{ios.dsym_file}"
    File.delete(dsym_file) if File.exist? dsym_file
    ios.destroy
    redirect_to :back
  end

  def download
    ios = Ios.find(params[:id])

    file = "public/uploads/ipa/#{ios.dsym_file}"
    send_file file, type: 'application/zip', x_sendfile: true
  end
end
