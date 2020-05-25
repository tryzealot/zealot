# frozen_string_literal: true

namespace :zealot do
  namespace :migration do
    task upgrade: :environment do
      Rake::Task['zealot:migration:upgrade_devices'].invoke if Device.count.zero? || Device.take.releases.empty?
    end

    # 把 Release.devices JSON 字符串转移到独立表 Device
    task upgrade_devices: :environment do
      puts 'Moving devices data from Release table into Device table'

      udids = []
      Release.find_each do |release|
        next if release.legacy_devices.empty?

        release.legacy_devices.each do |udid|
          udids << udid unless udids.include?(udid)

          device = Device.find_or_create_by!(udid: udid)
          release.devices << device
        end
      end

      puts "Valiting device data"
      if Device.count == udids.count

      end
    end
  end
end
