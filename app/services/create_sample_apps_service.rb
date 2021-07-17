# frozen_string_literal: true

class CreateSampleAppsService
  RELEASE_COUNT = 3

  def call(user)
    stardford_app user
    android_channels_app user
  end

  private

  def stardford_app(user)
    app_name = '演示应用'
    app_bundle_id = 'com.zealot.app-demo'
    schemes = %i[开发版 测试版 产品版]
    channels = %i[Android iOS]
    changelog = [
      {
        author: '管理员',
        date: '2019-10-24 23:0:24 +0800',
        message: 'release: 发布 0.1.0',
        email: 'admin@zealt.com'
      },
      {
        author: '管理员',
        date: '2019-10-23 17:41:41 +0800',
        message: 'fix: 修复 xxx 问题',
        email: 'admin@zealt.com'
      },
      {
        author: '管理员',
        date: '2019-10-22 11:11:11 +0800',
        message: 'feat: 初始化项目',
        email: 'admin@zealt.com'
      }
    ]

    app = create_app(app_name, user)

    schemes.each do |scheme_name|
      scheme = app.schemes.find_or_create_by name: scheme_name
      channels.each do |channel_name|
        channel = scheme.channels.find_or_create_by name: channel_name,
                                                    device_type: channel_name.downcase.to_sym
        bundle_id = generate_bundle_id app_bundle_id, channel
        release_type = case scheme.name
                       when '开发版'
                         'debug'
                       when '测试版'
                         channel.name == 'iOS' ? 'adhoc' : 'beta'
                       when '产品版'
                         'release'
                       end

        RELEASE_COUNT.times do
          generate_release(channel, bundle_id, release_type, changelog)
        end
      end
    end
  end

  def android_channels_app(user)
    app_name = '演示桌面'
    app_bundle_id = 'com.zealot.android.app-demo'
    schemes = %i[产品版]
    channels = %i[华为 小米 oppo viio 魅族 应用宝 百度 GooglePlay]
    changelog = "release: 发布 0.1.0\nfix: 修复 xxx 问题\nfeat: 初始化项目"

    app = create_app(app_name, user)

    schemes.each do |scheme_name|
      scheme = app.schemes.find_or_create_by name: scheme_name
      channels.each do |channel_name|
        channel = scheme.channels.find_or_create_by name: channel_name,
                                                    device_type: :android
        generate_release(channel, app_bundle_id, 'release', changelog)
      end
    end
  end

  def generate_release(channel, app_bundle_id, release_type, changelog)
    release = channel.releases.new
    release.bundle_id = app_bundle_id
    release.release_version = '1.0.0'
    release.build_version = '1'
    release.release_type = release_type
    release.source = 'API'
    release.branch = 'develop'
    release.git_commit = SecureRandom.hex
    release.changelog = changelog
    release.save validate: false
  end

  def create_app(name, user)
    App.find_or_create_by name: name do |a|
      a.users << user
    end
  end

  def generate_bundle_id(app_bundle_id, channel)
    "#{app_bundle_id}.#{channel.name.downcase}"
  end
end
