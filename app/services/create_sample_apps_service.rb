# frozen_string_literal: true

class CreateSampleAppsService
  APP_NAME = '演示应用'
  APP_BUNDLE_ID = 'com.zealot.app-demo'
  SCHEMES = %i[开发版 测试版 产品版].freeze
  CHANNELS = %i[Android iOS].freeze
  CHANGELOG = "release: 发布 0.1.0\nfix: 修复 xxx 问题\nfeat: 初始化项目"

  def call(user)
    app = App.find_or_create_by name: APP_NAME, user: user
    SCHEMES.each do |scheme_name|
      scheme = app.schemes.find_or_create_by name: scheme_name
      CHANNELS.each do |channel_name|
        channel = scheme.channels.find_or_create_by name: channel_name,
                                                    device_type: channel_name.downcase.to_sym
        bundle_id = generate_bundle_id channel
        release_type = case scheme.name
                       when '开发版'
                         'debug'
                       when '测试版'
                         channel_name == 'iOS' ? 'adhoc' : 'beta'
                       when '产品版'
                         'release'
                       end

        2.times do
          release = channel.releases.new
          release.bundle_id = bundle_id
          release.release_version = '1.0.0'
          release.build_version = '1'
          release.release_type = release_type
          release.source = 'API'
          release.branch = 'develop'
          release.git_commit = SecureRandom.hex
          release.changelog = CHANGELOG
          release.save validate: false
        end
      end
    end
  end

  private

  def generate_bundle_id(channel)
    "#{APP_BUNDLE_ID}.#{channel.name.downcase}"
  end
end
