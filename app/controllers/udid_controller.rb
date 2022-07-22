# frozen_string_literal: true

class UdidController < ApplicationController
  before_action :get_device_xml, only: :create
  before_action :render_profile, only: :install

  # GET /udid
  def index
    @title = t('udid.title')
    @qrcode = RQRCode::QRCode.new(udid_url)
  end

  # POST /udid/retrive
  def create
    redirect_to udid_url(
      udid: @device_attrs['UDID'],
      product: @device_attrs['PRODUCT'],
      serial: @device_attrs['SERIAL'],
      version: @device_attrs['VERSION']
    ), status: 301
  end

  # GET /udid/:udid
  def show
    @title = t('udid.show.title')
    @device = Device.find_by(udid: params[:udid])
    @channels = @device&.channels
    @apple_keys = @device&.apple_keys
    @all_apple_keys = AppleKey.all

    @channel_total = @channels&.count || 0
    @release_total = @device&.releases&.count || 0
    @apple_key_total = @all_apple_keys.size

    @result = if @apple_keys
                'related_apple_keys'
              elsif @all_apple_keys.size > 0
                'register_apple_key'
              else
                'unregister_device'
              end
  end

  # POST /udid/:udid/register
  def register
    apple_key = AppleKey.find(params[:apple_key_id])
    udid = params[:udid]
    name = [ 'Zealot注册', params[:product], SecureRandom.hex(4) ].compact.join('-') # Max 50 chars
    device = apple_key.register_device(udid, name)
    if device
      notice = t('activerecord.success.update', key: t('simple_form.labels.apple_key.devices'))
      redirect_to udid_result_path(params[:udid]), notice: notice
    else
      redirect_to udid_result_path(params[:udid]), alert: '注册失败！'
    end
  end

  # GET /udid/install
  def install
  end

  private

  def get_device_xml
    body = request.body.read

    p7sign = OpenSSL::PKCS7.new(body)
    store = OpenSSL::X509::Store.new
    p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)

    @device_attrs = Plist.parse_xml(p7sign.data)
  end

  def render_profile
    enable_tls = false # params[:tls].present?
    @udid = Rails.cache.fetch('ios-udid', expires_in: 1.week) { SecureRandom.uuid.upcase }
    content_type = params[:preview].present? ? 'application/xml' : 'application/x-apple-aspen-config'
    return render(content_type: content_type, layout: false) unless enable_tls

    # plist = render_to_string(layout: false)
    # server = File.read('public/certs/server.pem')
    # server_key = File.read('public/certs/key.pem')
    # server_pem = OpenSSL::X509::Certificate.new(server)
    # server_key_pem = OpenSSL::PKey::RSA.new(server_key)
    # sigend_plist = OpenSSL::PKCS7.sign(
    #   certificate, key,
    #   plist, [], OpenSSL::PKCS7::BINARY
    # )

    # render plain: sigend_plist, content_type: content_type, layout: false
  end

  # CERT_SUBJECT = "/C=CN/O=zealot/OU=tryzealot/OU=github/CN=Zealot"

  # def certificate
  #   @certificate ||= -> () do
  #     cert = OpenSSL::X509::Certificate.new
  #     cert.subject = cert.issuer = OpenSSL::X509::Name.parse(CERT_SUBJECT)
  #     cert.not_before = Time.now
  #     cert.not_after = Time.now + 365 * 24 * 60 * 60
  #     cert.public_key = key.public_key
  #     cert.serial = 0x0
  #     cert.version = 2

  #     ef = OpenSSL::X509::ExtensionFactory.new
  #     ef.subject_certificate = cert
  #     ef.issuer_certificate = cert

  #     cert.extensions = [
  #       ef.create_extension("basicConstraints","CA:TRUE", true),
  #       ef.create_extension("subjectKeyIdentifier", "hash"),
  #     ]
  #     cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always")
  #     cert.sign key, OpenSSL::Digest::SHA1.new
  #   end.call
  # end

  # def key
  #   @key ||= OpenSSL::PKey::RSA.new(2048)
  # end
end
