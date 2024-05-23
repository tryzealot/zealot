# frozen_string_literal: true

require 'securerandom'

class CreateSampleAppsService
  RELEASE_COUNT = 3

  def call(user)
    android_channels_app user
    stardford_app user
  end

  private

  def stardford_app(user)
    app_name = I18n.t('demo.app_name1')
    app_bundle_id = 'com.zealot.app-demo'
    channels = %i[Android iOS]
    schemes = [
      I18n.t('settings.preset_schemes.beta'),
      I18n.t('settings.preset_schemes.adhoc'),
      I18n.t('settings.preset_schemes.production'),
    ]
    changelog = [
      {
        author: I18n.t('settings.preset_role.developer'),
        date: '2019-10-24 23:0:24 +0800',
        message: 'bump 0.1.0',
        email: 'admin@zealt.com'
      },
      {
        author: I18n.t('settings.preset_role.developer'),
        date: '2019-10-23 17:41:41 +0800',
        message: 'fix: xxx',
        email: 'admin@zealt.com'
      },
      {
        author: I18n.t('settings.preset_role.developer'),
        date: '2019-10-22 11:11:11 +0800',
        message: 'feat: xxx done',
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
                       when I18n.t('settings.preset_schemes.beta')
                         'beta'
                       when I18n.t('settings.preset_schemes.adhoc')
                         'adhoc'
                       when I18n.t('settings.preset_schemes.production')
                         'release'
                       end

        RELEASE_COUNT.times do |i|
          generate_release(
            channel,
            bundle_id,
            release_type,
            changelog,
            build_version: (i + 1).to_s,
            device_type: 'iPhone'
          )
        end
      end
    end
  end

  def android_channels_app(user)
    app_name = I18n.t('demo.app_name2')
    app_bundle_id = 'com.zealot.android.app-demo'
    schemes = [ I18n.t('settings.preset_schemes.production') ]
    channels = I18n.t('demo.android_channels').values
    changelog = "bump 0.1.0\nfix: xxx\nfeat: xxx done"

    app = create_app(app_name, user)

    schemes.each do |scheme_name|
      scheme = app.schemes.find_or_create_by name: scheme_name
      channels.each_with_index do |channel_name, i|
        channel = scheme.channels.find_or_create_by name: channel_name,
                                                    device_type: :android
        generate_release(
          channel,
          app_bundle_id,
          'release',
          changelog,
          build_version: (i + 1).to_s,
          device_type: 'Phone'
        )
      end
    end
  end

  def generate_release(channel, app_bundle_id, release_type, changelog, build_version: '1', device_type: nil)
    Release.new(
      channel: channel,
      bundle_id: app_bundle_id,
      release_version: '1.0.0',
      build_version: build_version,
      release_type: release_type,
      source: 'API',
      branch: 'develop',
      device_type: device_type || channel.device_type,
      git_commit: SecureRandom.hex,
      changelog: changelog
    ).save(validate: false)
  end

  def generate_devices(release, count)
    count.times do
      release.devices << Device.create(
        udid: SecureRandom.uuid,
        model: DEVICE_MODEL[rand(DEVICE_MODEL.size - 1)],
        platform: 'IOS',
        status: 'ENABLED'
      )
    end
  end

  DEVICE_MODEL = [
    'iPhone 6',
    'iPhone 6s',
    'iPhone 6 Plus',
    'iPhone 7',
    'iPhone 7 Plus',
    'iPhone 8',
    'iPhone 8 Plus',
    'iPhone X',
    'iPhone XR',
    'iPhone XS',
    'iPhone XS Max',
    'iPhone 11',
    'iPhone 11 Pro',
    'iPhone 11 Pro Max',
    'iPhone 12',
    'iPhone 12 mini',
    'iPhone 12 Pro',
    'iPhone 12 Pro Max',
    'iPhone 13',
    'iPhone 13 Pro',
    'iPhone 13 Pro Max'
  ]

  def generate_bundle_id(app_bundle_id, channel)
    "#{app_bundle_id}.#{channel.name.downcase}"
  end

  def create_app(name, user)
    owner = user.is_a?(Array) ? user.first : user
    app = App.find_or_initialize_by(name:)
    return app unless app.new_record?

    app.save!
    app.create_owner(owner)
    app
  end
end
