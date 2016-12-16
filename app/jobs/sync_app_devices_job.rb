require 'spaceship'

class SyncAppDevicesJob < ApplicationJob
  queue_as :default

  def perform(_event, release)
    @release = release
    return if @release.release_type.blank? || @release.release_type.casecmp('inhouse').zero?

    extra = JSON.parse(release.extra)
    return if !extra['devices'] || extra['devices'].blank? || extra['devices'].size.zero?
    @devices = extra['devices']

    logger.info "Processing devices (#{@devices.size})"
    syncing!
  end

  def syncing!
    logger.info 'Syncing devices of release from iDP'
    accounts.each do |key, account|
      account_password_variable_name = "#{key.upcase}_PASSWORD"
      unless ENV.key?(account_password_variable_name)
        logger.info "No found password of account: #{account_password_variable_name}"
        next
      end

      ENV['FASTLANE_PASSWORD'] = ENV[account_password_variable_name]
      ENV['FASTLANE_TEAM_ID'] = account[:team_id] unless account.key?(:team_id)

      logger.info "[#{account[:user]}] Logining to sync ... "
      Spaceship.login(account[:user])
      Spaceship.select_team

      Spaceship::Portal.device.all(include_disabled: true).each do |item|
        sync_devices.each do |udid|
          next if udid != item.udid

          params = {
            name: item.name,
            udid: item.udid,
            model: item.model,
            platform: item.platform,
            device_type: item.device_type
          }

          device = Device.find_by(udid: udid)
          if device
            device.update!(params)
          else
            device = Device.new(params)
            device.save!
          end

          sync_devices.delete(udid)
        end
      end

      ENV.delete('FASTLANE_PASSWORD')
      ENV.delete('FASTLANE_TEAM_ID') unless account.key?(:team_id)
    end
  end

  def store_devices
    logger.info 'Store devices of release into the database'
    @devices.each do |udid|
      device = Device.find_by(udid: udid)
      next if device

      device = Device.new(udid: udid)
      device.save
    end
  end

  def sync_devices
    return @sync_devices if @sync_devices

    @sync_devices = @devices.each_with_object([]) do |udid, obj|
      device = Device.find_by(udid: udid)
      obj << udid if !device || device.name.blank?
    end
  end

  def accounts
    {
      qyer_inc: {
        user: 'yi.xiao@go2eu.com',
        team_id: '5PJA6N5A3B'
      },
      qyer_co_ltd: {
        user: 'enterpriseidp@qq.com'
      },
      qyer_inhouse: {
        user: 'enterprisetest@qq.com'
      }
    }
  end
end
