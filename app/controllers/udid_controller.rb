# frozen_string_literal: true

class UdidController < ApplicationController
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
      @device.start_sync_device_job(@apple_key.id)
    end

    redirect_to admin_apple_key_path(@apple_key.id)
  end

  # POST /udid/:udid/register
  def register
    apple_key = AppleKey.find(device_params[:apple_keys])
    name = device_params[:name]
    name = [ 'Zealot', params[:product], SecureRandom.hex(4) ].compact.join('-') if name.blank? # Max 50 chars
    udid = params[:udid]

    new_device = apple_key.register_device(udid, name)
    if new_device.errors
      flash[:alter] = new_device.errors.messages[:devices][0]
      return render :show, status: :unprocessable_entity
    end

    notice = t('activerecord.success.update', key: t('simple_form.labels.apple_key.devices'))
    redirect_to udid_path(params[:udid]), notice: notice, status: :see_other
  end

  # GET /udid/install
  def install
  end

  def qrcode
    render qrcode: udid_index_url, **qrcode_options
  end

  private

  def set_device_xml
    body = request.body.read

    p7sign = OpenSSL::PKCS7.new(body)
    store = OpenSSL::X509::Store.new
    p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)

    @device_attrs = Plist.parse_xml(p7sign.data)
  end

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

  def certificate
    @certificate ||= lambda do
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = Random.rand(2**16 - 2) + 1
      cert.subject = subject
      cert.issuer = issuer
      cert.not_before = create_date
      cert.not_after = expire_date
      cert.public_key = root_key.public_key

      cert_ext = OpenSSL::X509::ExtensionFactory.new
      cert_ext.subject_certificate = cert
      cert_ext.issuer_certificate = cert
      cert.add_extension(cert_ext.create_extension("basicConstraints","CA:TRUE",true))
      cert.add_extension(cert_ext.create_extension("keyUsage","keyCertSign, cRLSign", true))
      cert.add_extension(cert_ext.create_extension("subjectKeyIdentifier","hash",false))
      cert.add_extension(cert_ext.create_extension("authorityKeyIdentifier","keyid:always",false))
      cert.sign(root_key, digest)
      cert
    end.call
  end

  def subject
    @subject ||= OpenSSL::X509::Name.parse("/C=CN/O=tryzealot/OU=zealot/CN=#{Setting.site_title} Self-signed Authority")
  end

  def issuer
    @issuer ||= OpenSSL::X509::Name.parse("/C=CN/O=tryzealot/OU=zealot/CN=#{Setting.site_title}")
  end

  def root_key
    @key ||= OpenSSL::PKey::RSA.generate(2048)
  end

  def digest
    @digest ||= OpenSSL::Digest.new('SHA256')
  end

  def payload_uuid
    @payload_uuid ||= Rails.cache.fetch('ios-udid', expires_in: 1.week) { SecureRandom.uuid.upcase }
  end

  def create_date
    Time.now.utc
  end

  def expire_date
    expire_time = 1 * 365 * 24 * 60 * 60  # 1 year
    create_date + expire_time
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
    if @apple_keys
      # :registered_device
      'related_apple_keys'
    elsif @all_apple_keys.size > 0
      # :new_register_device
      'register_apple_key'
    else
      # :new_device
      'unregister_device'
    end
  end

  def set_apple_key
    @apple_key = AppleKey.find(params[:apple_key])
    authorize @apple_key
  end

  def device_params
    params.require(:device).permit(:name, :apple_keys, :sync_to_apple_key)
  end
end
