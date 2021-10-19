# frozen_string_literal: true

class CreateSampleAppsService
  include ActionView::Helpers::TranslationHelper

  RELEASE_COUNT = 3

  def call(user)
    stardford_app user
    android_channels_app user
  end

  private

  def stardford_app(user)
    app_name = t('demo.app_name1')
    app_bundle_id = 'com.zealot.app-demo'
    channels = %i[Android iOS]
    schemes = [
      t('settings.default_schemes.beta'),
      t('settings.default_schemes.adhoc'),
      t('settings.default_schemes.production'),
    ]
    changelog = [
      {
        author: t('settings.default_role.developer'),
        date: '2019-10-24 23:0:24 +0800',
        message: 'bump 0.1.0',
        email: 'admin@zealt.com'
      },
      {
        author: t('settings.default_role.developer'),
        date: '2019-10-23 17:41:41 +0800',
        message: 'fix: xxx',
        email: 'admin@zealt.com'
      },
      {
        author: t('settings.default_role.developer'),
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
                       when t('settings.default_schemes.beta')
                         'beta'
                       when t('settings.default_schemes.adhoc')
                         'adhoc'
                       when t('settings.default_schemes.production')
                         'release'
                       end

        RELEASE_COUNT.times do
          generate_release(channel, bundle_id, release_type, changelog)
        end
      end
    end
  end

  def android_channels_app(user)
    app_name = t('demo.app_name2')
    app_bundle_id = 'com.zealot.android.app-demo'
    schemes = [ t('settings.default_schemes.production') ]
    channels = t('demo.android_channels').values
    changelog = "bump 0.1.0\nfix: xxx\nfeat: xxx done"

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
    release.device_type = channel.device_type
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
