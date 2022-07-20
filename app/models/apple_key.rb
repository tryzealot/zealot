# frozen_string_literal: true

class AppleKey < ApplicationRecord
  has_one :team, class_name: 'AppleTeam', foreign_key: 'apple_key_id', dependent: :destroy
  has_and_belongs_to_many :devices

  # NOTE: to be or not to be?
  # encrypts :private_key

  validates :issuer_id, :key_id, :private_key, :filename, :checksum, presence: true
  validates :checksum, uniqueness: true, on: :create
  validate :private_key_format, on: :create
  validate :appstoreconnect_api_role_permissions, on: :create

  before_validation :generate_checksum
  after_save :create_relate_team

  PRIVATE_KEY_HYPHENS = '-----'

  def encrypted_private_key
    @encrypted_private_key ||= ->() do
      content = private_key.split("\n")
                           .delete_if do |s|
                              s.include?('PRIVATE KEY') &&
                              s.start_with?(PRIVATE_KEY_HYPHENS) &&
                              s.end_with?(PRIVATE_KEY_HYPHENS)
                           end
                           .join('')
      "#{content[0..8]}********#{content[-8..-1]}"
    end.call
  end

  def last_synced_at
    devices&.last&.updated_at
  end

  def sync_devices
    response_devices = client.devices.all_pages(flatten: true)
    logger.debug "Got #{response_devices.size} devices from apple key #{id}"
    response_devices.each do |response_device|
      current_udid = response_device.udid
      record_data = {
        name: response_device.name,
        model: response_device.model,
        platform: response_device.platform,
        created_at: Time.parse(response_device.added_date)
      }

      model = Device.find_by(udid: current_udid)
      if model.blank?
        model = Device.create(record_data.merge(udid: current_udid))
      else
        model.update!(record_data)
      end

      devices << model unless devices.exists?(model.id)
    end

    true
  rescue => e
    raise e
    false
  end

  def device(udid)
    client.device(udid)
  end

  private

  def create_relate_team
    cert = client.distribution_certificates.to_model
    raise 'Not found cert, create it first' if cert.nil?

    create_team(
      team_id: cert.team_id,
      name: cert.name
    )
  end

  def private_key_format
    OpenSSL::PKey.read(private_key)
  rescue => e
    # OpenSSL::PKey::PKeyError
    errors.add(:private_key, "[#{e.class}] #{e.message}")
  end

  def appstoreconnect_api_role_permissions
    client.devices
  rescue TinyAppstoreConnect::InvalidUserCredentialsError
    errors.add(:key_id, '用户身份认证失败，请重新检查各项参数是否正确')
  rescue TinyAppstoreConnect::ForbiddenError
    errors.add(:key_id, '密钥权限太低，重新生成一个最低限度为【开发者】权限的密钥')
  rescue => e
    logger.error "Throws an error: #{e.message}, with trace: #{e.backtrace.join("\n")}"
    errors.add(:key_id, "未知错误 [#{e.class}]: #{e.message}")
  end

  def generate_checksum
    return if private_key.blank?

    self.checksum = Digest::SHA1.hexdigest(private_key)
  end

  def client
    @client ||= TinyAppstoreConnect::Client.new(
      issuer_id: issuer_id,
      key_id: key_id,
      private_key: private_key
    )
  end
end
