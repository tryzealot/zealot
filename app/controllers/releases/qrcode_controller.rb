# frozen_string_literal: true

class Releases::QrcodeController < ApplicationController
  include Qrcode

  before_action :set_release

  # Show the QR code for the release
  # GET /apps/:slug/(:version)/qrcode(/:size)(/:theme).(:format)
  def show
    content = friendly_channel_release_url(@release.channel, @release)
    render_qrcode(content)
  end

  private

  def set_release
    @release = Release.find params[:release_id]
  end
end
