# frozen_string_literal: true

class AppleKey < ApplicationRecord
  has_one :team, class_name: 'AppleTeam', foreign_key: 'apple_key_id', dependent: :destroy
  has_many :apple_keys_devices, class_name: 'AppleKeyDevice'
  has_many :devices, through: :apple_keys_devices

  validates :issuer_id, :key_id, :private_key, :filename, presence: true
  validates :checksum, uniqueness: true, on: :create, if: :requires_fields?
  validate :private_key_format, on: :create, if: :requires_fields?
  validate :appstoreconnect_api_role_permissions, on: :create, if: :requires_fields?

  before_validation :generate_checksum

  def private_key_filename
    @private_key_filename ||= "#{key_id}.key"
  end

  def last_synced_at
    devices&.last&.updated_at
  end

  def sync_devices
    response_devices = client.devices.all_pages(flatten: true)
    AppleKeyDevice.where(apple_key: self).delete_all
    response_devices.each do |response_device|
      Device.create_from_api(response_device) do |device|
        devices << device
      end
    end

    true
  rescue => e
    logger.error "Sync device raise an exception: #{e}"
    false
  end

  def register_device(udid, name = nil, platform = 'IOS')
    remote_device = client.device(udid: udid)
    db_device = Device.find_by(udid: udid)
    return db_device if remote_device && db_device

    if remote_device && !db_device
      devices << remote_device
      return remote_device
    end

    response_device = client.create_device(udid, name, platform: platform).to_model
    Device.create_from_api(response_device) do |device|
      devices << device

      # return value
      device
    end
  rescue TinyAppstoreConnect::InvalidEntityError => e
    # Incorrect UDID format: An invalid value '00008020-001430D41A68002E1' was provided for the parameter 'udid'.
    # UDID exists: A device with number '00008020-001430D41A680022' already exists on this team.
    logger.error "Device may exists or the other error in apple key #{id}: #{e}"
    message = e.errors[0]['detail']
    is_exists = message.include?('already exists')

    # udid had registered, but not exists in zealot system, needs to force sync device
    if is_exists
      sync_devices
      return self
    end

    invaild_device = Device.new
    # invaild udid
    if message.include?('invalid value')
      # This is never happen, never ever!
      invaild_device.errors.add(:name, :invalid_value, value: udid)
    else
      invaild_device.errors.add(:name, :api, message: message)
    end

    invaild_device
  rescue => e
    logger.error "Register device raise an exception: #{e}"
    logger.error e.backtrace.join("\n")

    message = e.respond_to?(:errors) ? errors[0]['detail'] : e.message

    invaild_device = Device.new
    invaild_device.errors.add(:name, :unknown, message: message)
    invaild_device
  end

  def update_device_name(device)
    client.rename_device(device.name, id: device.device_id, udid: device.udid)
  rescue TinyAppstoreConnect::InvalidEntityError => e
    logger.error "Device may not exists or the other error in apple key #{id}: #{e}"
  end

  def sync_team
    cert = apple_distribtion_certiticate
    logger.debug "Fetching distribution_certificates is #{cert.name}"
    create_team(
      team_id: cert.team_id,
      name: cert.name
    )
  end

  def sync_devices_job
    SyncAppleDevicesJob.perform_later(id)
  end

  private

  def private_key_format
    OpenSSL::PKey.read(private_key)
  rescue => e
    # OpenSSL::PKey::PKeyError
    errors.add(:private_key, "[#{e.class}] #{e.message}")
  end

  # Detect if the API key has the required permissions to access App Store Connect. and 
  # if the distribution certificate exists.
  def appstoreconnect_api_role_permissions
    if apple_distribtion_certiticate.blank?
      errors.add(:issuer_id, :missing_distribution_certificate)
    end
  rescue TinyAppstoreConnect::ForbiddenError => e
    if e.message.include?('required agreement is missing or has expired')
      errors.add(:key_id, :required_agreement_missing_or_expired)
    else
      errors.add(:key_id, :forbidden)
    end
  rescue TinyAppstoreConnect::InvalidUserCredentialsError
    errors.add(:key_id, :unauthorized)
  rescue => e
    logger.error "Throws an error: #{e.message}, with trace: #{e.backtrace.join("\n")}"
    errors.add(:key_id, :unknown, message: "[#{e.class}]: #{e.message}")
  end

  def apple_distribtion_certiticate
    @apple_distribtion_certiticate ||= client.distribution_certificates.to_model
  end

  def requires_fields?
    issuer_id.present? && key_id.present? || private_key.present?
  end

  def client
    @client ||= TinyAppstoreConnect::Client.new(
      issuer_id: issuer_id,
      key_id: key_id,
      private_key: private_key
    )
  end

  def generate_checksum
    return if private_key.blank?

    self.checksum = Digest::SHA1.hexdigest(private_key)
  end
end
