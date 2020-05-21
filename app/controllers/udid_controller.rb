class UdidController < ApplicationController
  def index
  end

  def create
    body = request.body.read

    p7sign = OpenSSL::PKCS7.new(body)
    store = OpenSSL::X509::Store.new
    p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)

    attrs = Plist::parse_xml(p7sign.data)

    redirect_to udid_result_url(
      udid: attrs['UDID'],
      product: attrs['PRODUCT'],
      serial: attrs['SERIAL'],
      version: attrs['VERSION']
      ), status: 301
  end

  def show
  end

  def install
    @udid = Rails.cache.fetch('ios-udid', expires_in: 1.week) { SecureRandom.uuid.upcase }

    content_type = params[:preview].present? ? 'html/text' : 'application/x-apple-aspen-config'

    plist = render_to_string(layout: false)

    server = File.read('public/certs/server.pem')
    server_key = File.read('public/certs/key.pem')

    server_pem = OpenSSL::X509::Certificate.new(server)
    server_key_pem = OpenSSL::PKey::RSA.new(server_key)

    sigend_plist = OpenSSL::PKCS7.sign(
      server_pem, server_key_pem,
      plist, [], OpenSSL::PKCS7::BINARY
    )

    render plain: plist, content_type: content_type, layout: false
  end
end
