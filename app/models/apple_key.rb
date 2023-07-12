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
  after_create :start_sync_device_job

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
      logger.debug "Device is: #{response_device.attributes}"
      Device.create_from_api(response_device) do |device|
        devices << device unless devices.exists?(device.id)
      end
    end

    true
  rescue => e
    logger.error "Sync device raise an exception: #{e}"
    false
  end

  def register_device(udid, name = nil)
    return device if (device = Device.find_by(udid: udid))

    response_device = client.create_device(udid, name).to_model
    Device.create_from_api(response_device) do |device|
      devices << device
    end
  rescue TinyAppstoreConnect::InvalidEntityError => e
    # Incorrect UDID format: An invalid value '00008020-001430D41A68002E1' was provided for the parameter 'udid'.
    # UDID exists: A device with number '00008020-001430D41A680022' already exists on this team.
    logger.error "Device may exists or the other error in apple key #{id}: #{e}"
    message = e.errors[0]['detail']
    is_exists = message.include?('already exists')

    # udid had registered, force sync device
    if is_exists
      sync_devices
      return self
    end

    # invaild udid
    if message.include?('invalid value')
      # This is never happen, never ever!
      errors.add(:devices, :invalid_value, value: udid)
    else
      errors.add(:devices, :api, message: message)
    end

    self
  rescue => e
    logger.error "Register device raise an exception: #{e}"

    message = e.respond_to?(:errors) ? errors[0]['detail'] : e.message
    errors.add(:devices, :unknown, message: message)

    self
  end

  def update_device_name(device)
    response_device = client.rename_device(device.udid, device.name)
  rescue TinyAppstoreConnect::InvalidEntityError => e
    logger.error "Device may not exists or the other error in apple key #{id}: #{e}"
  end

  private

  def create_relate_team
    cert = client.distribution_certificates.to_model
    logger.debug "Fetching distribution_certificates is #{cert.attributes}"
    raise 'Not found cert, create it first' if cert.blank?

    create_team(
      team_id: cert.team_id,
      name: cert.name
    )
  end

  def start_sync_device_job
    SyncAppleDevicesJob.perform_later(id)
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
