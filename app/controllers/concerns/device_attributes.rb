# frozen_string_literal: true

module DeviceAttributes
  extend ActiveSupport::Concern

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
end
