namespace :devices do

  task store: :environment do
    App.all.each do |app|
      next if app.device_type.casecmp('android').zero?

      puts "- #{app.name}"
      app.releases.all.each do |release|
        next if !release.release_type.blank? && release.release_type.casecmp('inhouse').zero?
        extra = JSON.parse(release.extra)
        next if !extra['devices'] || extra['devices'].blank? || extra['devices'].size.zero?

        puts " * #{release.id}"
        release.update_attribute(:devices, JSON.dump(extra['devices'])) if release.devices.blank? || ['[]', 'null', 'nil'].include?(release.devices)

        extra['devices'].each do |udid|
          device = Device.find_by(udid: udid)
          next if device

          puts "   # #{udid}"

          device = Device.new(udid: udid)
          device.save
        end
      end
    end
  end

  # task down: :environment do
  #   require 'spaceship'
  #
  #   ['yi.xiao@go2eu.com', 'enterpriseidp@qq.com', 'enterprisetest@qq.com'].each do |account|
  #     puts "Log in to iDP ... #{account}"
  #     ENV['FASTLANE_TEAM_ID'] = '5PJA6N5A3B' if account == 'yi.xiao@go2eu.com'
  #
  #     Spaceship.login(account)
  #     Spaceship.select_team
  #
  #     Spaceship::Portal.device.all(include_disabled: true).each do |item|
  #       device = Device.find_by(udid: item.udid)
  #       params = {
  #         name: item.name,
  #         udid: item.udid,
  #         model: item.model,
  #         platform: item.platform,
  #         device_type: item.device_type
  #       }
  #
  #       puts " * #{item.udid} ... "
  #       if device
  #         device.update!(params)
  #       else
  #         device = Device.new(params)
  #         device.save!
  #       end
  #     end
  #
  #     ENV.delete('FASTLANE_TEAM_ID') if account == 'yi.xiao@go2eu.com'
  #   end
  # end
end
