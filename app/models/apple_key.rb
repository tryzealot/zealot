# frozen_string_literal: true

class AppleKey < ApplicationRecord
  has_one :team, class_name: 'AppleTeam', foreign_key: 'apple_key_id', dependent: :destroy
  has_and_belongs_to_many :devices

  validates :issuer_id, :key_id, :private_key, :filename, :checksum, presence: true
  validates :checksum, uniqueness: true, on: :create
  validate :private_key_format, on: :create
  validate :appstoreconnect_api_role_permissions, on: :create
  validate :distribution_certificate, on: :create

  before_validation :generate_checksum
  after_save :create_relate_team
  after_create :start_sync_device_job

  def private_key_filename
    @private_key_filename ||= "#{key_id}.key"
  end

  def last_synced_at
    devices&.last&.updated_at
  end

  def sync_devices
    response_devices = client.devices.all_pages(flatten: true)
    logger.debug "Got #{response_devices.size} devices from apple key #{id}"
    response_devices.each do |response_device|
      Device.create_from_api(response_device) do |device|
        devices << device unless devices.exists?(device.id)
      end
    end

    true
  rescue => e
    logger.error "Sync device raise an exception: #{e}"
    false
  end

  def register_device(udid, name = nil, platform = 'IOS')
    if (existed_device = Device.find_by(udid: udid))
      return existed_device
    end

    response_device = client.create_device(udid, name, platform: platform).to_model
    Device.create_from_api(response_device) do |device|
      devices << device

      # pass the return to block
      device
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
    logger.error e.backtrace.join("\n")

    message = e.respond_to?(:errors) ? errors[0]['detail'] : e.message
    errors.add(:devices, :unknown, message: message)

    self
  end

  def update_device_name(device)
    response_device = client.rename_device(device.name, id: device.device_id, udid: device.udid)
  rescue TinyAppstoreConnect::InvalidEntityError => e
    logger.error "Device may not exists or the other error in apple key #{id}: #{e}"
  end

  private

  def create_relate_team
    cert = apple_distribtion_certiticate
    logger.debug "Fetching distribution_certificates is #{cert.name}"
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
    errors.add(:key_id, :unauthorized)
  rescue TinyAppstoreConnect::ForbiddenError
    errors.add(:key_id, :forbidden)
  rescue => e
    logger.error "Throws an error: #{e.message}, with trace: #{e.backtrace.join("\n")}"
    errors.add(:key_id, :unknown, message: "[#{e.class}]: #{e.message}")
  end

  def distribution_certificate
    if apple_distribtion_certiticate.blank?
      errors.add(:issuer_id, :missing_distribution_certificate)
    end
  end

  def apple_distribtion_certiticate
    @apple_distribtion_certiticate ||= client.distribution_certificates.to_model
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
