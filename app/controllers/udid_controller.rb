# frozen_string_literal: true

class UdidController < ApplicationController
  include DeviceAttributes
  include Qrcode

  before_action :set_device_xml, only: :create
  before_action :set_device_metadata, only: %i[show edit update register]
  before_action :render_profile, only: :install
  before_action :set_apple_key, only: %i[edit update]

  # GET /udid
  def index
    @title = t('udid.title')
  end

  # POST /udid/retrive
  def create
    redirect_to udid_url(
      udid: @device_attrs['UDID'],
      product: @device_attrs['PRODUCT'],
      serial: @device_attrs['SERIAL'],
      version: @device_attrs['VERSION']
    ), status: :moved_permanently
  end

  # GET /udid/:udid
  def show
  end

  # GET /udid/:udid/edit
  def edit
  end

  # PATCH /udid/:udid
  def update
    unless @device.update(device_params)
      return render :edit, status: :unprocessable_entity
    end

    if device_params[:sync_to_apple_key].to_i == 1
      @device.sync_devices_job(@apple_key.id)
    end

    redirect_to admin_apple_key_path(@apple_key.id)
  end

  # POST /udid/:udid/register
  def register
    apple_key = AppleKey.find(device_params[:apple_keys])
    name = device_params[:name]
    udid = device_params[:udid]
    platform = device_params[:platform].downcase.include?('iphone') ? 'IOS' : 'MAC_OS'
    name = [ 'Zealot', platform, SecureRandom.hex(4) ].compact.join('-') if name.blank? # Max 50 chars

    new_device = apple_key.register_device(udid, name, platform)
    if new_device.errors.present?
      logger.debug "Register failed with errors: #{new_device.errors.full_messages}"
      error_message = new_device.errors.messages[:name].join(' / ')
      flash.now[:warn] = error_message if error_message.present?
      return render :show, status: :unprocessable_entity
    end

    notice = t('activerecord.success.update', key: t('simple_form.labels.apple_key.devices'))
    redirect_to udid_path(params[:udid]), notice: notice, status: :see_other
  end

  # GET /udid/install
  def install
  end

  # GET /udid/qrcode
  def qrcode
    render_qrcode(udid_index_url)
  end

  private

  def render_profile
    enable_tls = params[:tls] == 'true'
    preview = params[:preview] == 'true'

    @udid = payload_uuid
    content_type = preview ? 'application/xml' : 'application/x-apple-aspen-config'
    profile_data = render_to_string(content_type: content_type, layout: false)
    unless enable_tls
      return render(plain: profile_data, content_type: content_type, layout: false)
    end

    signing_flags = OpenSSL::PKCS7::BINARY
    sigend = OpenSSL::PKCS7.sign(certificate, root_key, profile_data, [], signing_flags)
    render plain: sigend.to_der, content_type: content_type, layout: false
  end

  def set_device_xml
    body = request.body.read

    p7sign = OpenSSL::PKCS7.new(body)
    store = OpenSSL::X509::Store.new
    p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)

    @device_attrs = Plist.parse_xml(p7sign.data)
  end

  def set_device_metadata
    @title = t('udid.show.title')
    @device = Device.find_by(udid: params[:udid])
    @channels = @device&.channels
    @apple_keys = @device&.apple_keys
    @all_apple_keys = AppleKey.all

    @channel_total = @channels&.count || 0
    @release_total = @device&.releases&.count || 0
    @apple_key_total = @all_apple_keys.size
    @result = device_status
  end

  def device_status
    @device_status = if @apple_keys
                       :registered_device
                     elsif @all_apple_keys.size > 0
                       :new_register_device
                     else
                       :new_device
                     end
  end

  def set_apple_key
    @apple_key = AppleKey.find(params[:apple_key])
    authorize @apple_key
  end

  def device_params
    @device_params ||= params.require(:device).permit(:name, :udid, :platform, :apple_keys, :sync_to_apple_key)
  end
end
