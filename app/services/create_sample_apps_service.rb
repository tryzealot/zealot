# frozen_string_literal: true

require 'securerandom'

class CreateSampleAppsService # rubocop:disable Metrics/ClassLength
  RELEASE_COUNT = 3

  def call(user)
    create_sample_apps(user)

    if Setting.demo_mode
      create_sample_teardown(user)
      create_sample_debug_files
    end
  end

  private

  def create_sample_apps(user)
    android_channels_app user
    stardford_app user
  end

  def create_sample_debug_files
    app = App.take
    create_dsym_teardown(app)
    create_proguard_teardown(app)
  end

  def create_sample_teardown(user)
    create_ios_teardown(user)
    create_android_teardown(user)
  end

  DSYMS = [
    {
      "id": 4,
      "debug_file_id": 4,
      "uuid": "3c00ac25-7db1-3e8a-96f5-ff5806141896",
      "type": "arm64",
      "object": "NotificationContent",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.NotificationContent"
      },
      "size": 1057398,
      "created_at": "2024-05-31T13:32:24.214+08:00",
      "updated_at": "2024-05-31T13:32:24.214+08:00"
    },
    {
      "id": 5,
      "debug_file_id": 4,
      "uuid": "f80dc2f3-8fc8-3049-aa6d-ffc1db208757",
      "type": "arm64",
      "object": "NotificationExtension",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.NotificationExtension"
      },
      "size": 570464,
      "created_at": "2024-05-31T13:32:24.226+08:00",
      "updated_at": "2024-05-31T13:32:24.226+08:00"
    },
    {
      "id": 6,
      "debug_file_id": 4,
      "uuid": "c2a71eb6-afb4-3d92-ab18-1756d798db68",
      "type": "armv7k",
      "object": "Pocket Casts Watch App",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.watchkitapp"
      },
      "size": 7392965,
      "created_at": "2024-05-31T13:32:24.259+08:00",
      "updated_at": "2024-05-31T13:32:24.259+08:00"
    },
    {
      "id": 7,
      "debug_file_id": 4,
      "uuid": "5179f8d7-8203-3471-afea-5126d77846fc",
      "type": "arm64_32v8",
      "object": "Pocket Casts Watch App",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.watchkitapp"
      },
      "size": 7192701,
      "created_at": "2024-05-31T13:32:24.285+08:00",
      "updated_at": "2024-05-31T13:32:24.285+08:00"
    },
    {
      "id": 8,
      "debug_file_id": 4,
      "uuid": "a3a7418d-5f17-38f2-8402-fdd95f9d4559",
      "type": "arm64",
      "object": "Pocket Casts Watch App",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.watchkitapp"
      },
      "size": 7665427,
      "created_at": "2024-05-31T13:32:24.300+08:00",
      "updated_at": "2024-05-31T13:32:24.300+08:00"
    },
    {
      "id": 9,
      "debug_file_id": 4,
      "uuid": "6515a202-c4cd-3349-b890-b140c1675606",
      "type": "arm64",
      "object": "PocketCastsDataModel",
      "data": { "main": false, "identifier": "PocketCastsDataModel" },
      "size": 3788235,
      "created_at": "2024-05-31T13:32:24.319+08:00",
      "updated_at": "2024-05-31T13:32:24.319+08:00"
    },
    {
      "id": 10,
      "debug_file_id": 4,
      "uuid": "ddf530ff-33ee-3a42-8e3f-4d88894a4516",
      "type": "armv7k",
      "object": "PocketCastsDataModel",
      "data": { "main": false, "identifier": "PocketCastsDataModel" },
      "size": 3321981,
      "created_at": "2024-05-31T13:32:24.341+08:00",
      "updated_at": "2024-05-31T13:32:24.341+08:00"
    },
    {
      "id": 11,
      "debug_file_id": 4,
      "uuid": "da1c30a2-fbbc-35f1-b665-c7280e33e8ff",
      "type": "arm64_32v8",
      "object": "PocketCastsDataModel",
      "data": { "main": false, "identifier": "PocketCastsDataModel" },
      "size": 3245624,
      "created_at": "2024-05-31T13:32:24.357+08:00",
      "updated_at": "2024-05-31T13:32:24.357+08:00"
    },
    {
      "id": 12,
      "debug_file_id": 4,
      "uuid": "8bfa39bb-40ab-32e1-bf31-cadee3bd3236",
      "type": "arm64",
      "object": "PocketCastsDataModel",
      "data": { "main": false, "identifier": "PocketCastsDataModel" },
      "size": 3561719,
      "created_at": "2024-05-31T13:32:24.373+08:00",
      "updated_at": "2024-05-31T13:32:24.373+08:00"
    },
    {
      "id": 13,
      "debug_file_id": 4,
      "uuid": "50c3d7db-1968-3f94-8381-3dd62fa1b93f",
      "type": "arm64",
      "object": "PocketCastsServer",
      "data": { "main": false, "identifier": "PocketCastsServer" },
      "size": 13173618,
      "created_at": "2024-05-31T13:32:24.472+08:00",
      "updated_at": "2024-05-31T13:32:24.472+08:00"
    },
    {
      "id": 14,
      "debug_file_id": 4,
      "uuid": "8062ee0e-7b53-3631-bafa-1c504622f5d7",
      "type": "armv7k",
      "object": "PocketCastsServer",
      "data": { "main": false, "identifier": "PocketCastsServer" },
      "size": 12280214,
      "created_at": "2024-05-31T13:32:24.506+08:00",
      "updated_at": "2024-05-31T13:32:24.506+08:00"
    },
    {
      "id": 15,
      "debug_file_id": 4,
      "uuid": "7b3e1b73-2b89-3924-978d-28427826eb07",
      "type": "arm64_32v8",
      "object": "PocketCastsServer",
      "data": { "main": false, "identifier": "PocketCastsServer" },
      "size": 11927290,
      "created_at": "2024-05-31T13:32:24.512+08:00",
      "updated_at": "2024-05-31T13:32:24.512+08:00"
    },
    {
      "id": 16,
      "debug_file_id": 4,
      "uuid": "01789939-a624-3a0a-8823-06b23e892904",
      "type": "arm64",
      "object": "PocketCastsServer",
      "data": { "main": false, "identifier": "PocketCastsServer" },
      "size": 12879191,
      "created_at": "2024-05-31T13:32:24.519+08:00",
      "updated_at": "2024-05-31T13:32:24.519+08:00"
    },
    {
      "id": 17,
      "debug_file_id": 4,
      "uuid": "563a768a-f2b5-3875-88bf-477e0875bba5",
      "type": "arm64",
      "object": "PocketCastsUtils",
      "data": { "main": false, "identifier": "PocketCastsUtils" },
      "size": 1632283,
      "created_at": "2024-05-31T13:32:24.526+08:00",
      "updated_at": "2024-05-31T13:32:24.526+08:00"
    },
    {
      "id": 18,
      "debug_file_id": 4,
      "uuid": "6ebbd681-5551-355e-8770-c424f0cabe45",
      "type": "armv7k",
      "object": "PocketCastsUtils",
      "data": { "main": false, "identifier": "PocketCastsUtils" },
      "size": 1295904,
      "created_at": "2024-05-31T13:32:24.537+08:00",
      "updated_at": "2024-05-31T13:32:24.537+08:00"
    },
    {
      "id": 19,
      "debug_file_id": 4,
      "uuid": "d70c67e8-075b-3662-9693-dd890c04ff10",
      "type": "arm64_32v8",
      "object": "PocketCastsUtils",
      "data": { "main": false, "identifier": "PocketCastsUtils" },
      "size": 1276919,
      "created_at": "2024-05-31T13:32:24.544+08:00",
      "updated_at": "2024-05-31T13:32:24.544+08:00"
    },
    {
      "id": 20,
      "debug_file_id": 4,
      "uuid": "df8dfb75-03e5-3faa-9807-ad1d260b7c94",
      "type": "arm64",
      "object": "PocketCastsUtils",
      "data": { "main": false, "identifier": "PocketCastsUtils" },
      "size": 1317115,
      "created_at": "2024-05-31T13:32:24.550+08:00",
      "updated_at": "2024-05-31T13:32:24.550+08:00"
    },
    {
      "id": 21,
      "debug_file_id": 4,
      "uuid": "2a5807e3-9649-3d86-9e56-fb8bc476cbc4",
      "type": "arm64",
      "object": "PodcastsIntents",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.PodcastsIntents"
      },
      "size": 2124867,
      "created_at": "2024-05-31T13:32:24.565+08:00",
      "updated_at": "2024-05-31T13:32:24.565+08:00"
    },
    {
      "id": 22,
      "debug_file_id": 4,
      "uuid": "6b712f56-fabf-3f62-b816-def3c1bdb841",
      "type": "arm64",
      "object": "PodcastsIntentsUI",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.PodcastsIntentsUI"
      },
      "size": 1703750,
      "created_at": "2024-05-31T13:32:24.573+08:00",
      "updated_at": "2024-05-31T13:32:24.573+08:00"
    },
    {
      "id": 23,
      "debug_file_id": 4,
      "uuid": "163167d7-d615-340e-9d2d-098722792164",
      "type": "arm64",
      "object": "Share Extension",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.Share-Extension"
      },
      "size": 43103,
      "created_at": "2024-05-31T13:32:24.580+08:00",
      "updated_at": "2024-05-31T13:32:24.580+08:00"
    },
    {
      "id": 24,
      "debug_file_id": 4,
      "uuid": "5f3ddc87-f850-30c8-9753-707d2a28de19",
      "type": "arm64",
      "object": "WidgetExtension",
      "data": {
        "main": false,
        "identifier": "au.com.shiftyjelly.podcasts.WidgetExtension"
      },
      "size": 1954146,
      "created_at": "2024-05-31T13:32:24.587+08:00",
      "updated_at": "2024-05-31T13:32:24.587+08:00"
    },
    {
      "id": 25,
      "debug_file_id": 4,
      "uuid": "641b0cf5-f097-342c-a70b-2fd03e97d80c",
      "type": "arm64",
      "object": "podcasts",
      "data": { "main": true, "identifier": "au.com.shiftyjelly.podcasts" },
      "size": 60806584,
      "created_at": "2024-05-31T13:32:24.628+08:00",
      "updated_at": "2024-05-31T13:32:24.628+08:00"
    }
  ]

  PROGUARDS = [
    {
      "id": 26,
      "debug_file_id": 5,
      "uuid": "81384aeb-4837-5f73-a771-417b4399a483",
      "type": "proguard",
      "object": "com.icyleaf.appinfo",
      "data": {
        "files": [
          { "name": "AndroidManifest.xml", "size": 1268 },
          { "name": "R.txt", "size": 147585 },
          { "name": "mapping.txt", "size": 1666940 }
        ]
      },
      "size": 39204,
      "created_at": "2024-05-31T13:40:18.451+08:00",
      "updated_at": "2024-05-31T13:40:18.451+08:00"
    }
  ]

  def create_dsym_teardown(app)
    df = DebugFile.find_or_initialize_by(checksum: '67629032310d9c58d73d541ee245dac3') do |m|
      m.app = app
      m.device_type = 'iOS'
      m.release_version = '7.64'
      m.build_version = '7.64.0.4'
      m.file = 'pocketcastdSYM.zip'
    end
    df.save!(validate: false)

    DSYMS.each do |data|
      df.metadata.find_or_create_by(data)
    end
  end

  def create_proguard_teardown(app)
    df = DebugFile.find_or_initialize_by(checksum: '877b4849d2ef5ebacc7327435ced5117') do |m|
      m.app = app
      m.device_type = 'Android'
      m.release_version = '7.64'
      m.build_version = '9236'
      m.file = 'pocketcastproguard.zip'
    end
    df.save!(validate: false)

    PROGUARDS.each do |data|
      df.metadata.find_or_create_by(data)
    end
  end

  def create_ios_teardown(user) # rubocop:disable Metrics/MethodLength
    metadata = Metadatum.find_or_initialize_by(bundle_id: 'au.com.shiftyjelly.podcasts') do |m|
      m.user = the_user(user)
      m.platform = 'ios'
      m.device = 'universal'
      m.name = 'Pocket Casts'
      m.release_version = '7.64'
      m.build_version = '7.64.0.4'
      m.size = 72968205
      m.min_sdk_version = '15.0'
      m.release_type = 'enterprise'
      m.url_schemes = [
        [['pktc']],
        [['com.googleusercontent.apps.910146533958-ev91pir0snj2c7lt49qfj2c838hevs7f']]
      ]
      m.mobileprovision = {
        'uuid': '573eebfd-619d-4996-a37d-5889c24b8cd7',
        'team_name': 'Automattic, Inc.',
        'created_at': '2024-04-12T21:15:25.000+00:00',
        'expired_at': '2025-04-12T18:29:34.000+00:00',
        'profile_name': 'match AppStore au.com.shiftyjelly.podcasts',
        'team_identifier': ['PZYM8XX95Q']
      }
      m.developer_certs = [
        {
          'name': 'Apple Distribution: Automattic, Inc. (PZYM8XX95Q)',
          'digest': 'sha256',
          'format': 'x509',
          'issuer': [
            ['CN', 'Apple Worldwide Developer Relations Certification Authority'],
            ['OU', 'G3'],
            ['O', 'Apple Inc.'],
            ['C', 'US']
          ],
          'serial': {
            'hex': '0x27d6821ce43dd94733e4c22c3fbb907e',
            'number': '52953682365612550053558674408508985470'
          },
          'subject': [
            ['UID', 'PZYM8XX95Q'],
            ['CN', 'Apple Distribution: Automattic, Inc. (PZYM8XX95Q)'],
            ['OU', 'PZYM8XX95Q'],
            ['O', 'Automattic, Inc.'],
            ['C', 'US']
          ],
          'version': 'v3',
          'algorithem': 'rsa',
          'created_at': '2024-04-12T18:29:35.000Z',
          'expired_at': '2025-04-12T18:29:34.000Z',
          'fingerprint': {
            'md5': '7a:a7:8e:d8:99:69:01:b6:21:5b:ad:f4:33:85:f9:56',
            'sha1': 'dc:0e:a8:9a:1b:da:ce:ed:18:02:7b:6f:39:bd:50:6f:06:41:42:aa',
            'sha256': 'f4:22:c6:11:04:e3:13:39:d4:e6:64:fe:09:c1:99:fe:00:78:65:56:f0:7f:59:c8:81:3b:8c:69:ff:34:a8:e3'
          }
        }
      ]
      m.entitlements = {
        'get-task-allow': false,
        'aps-environment': 'production',
        'beta-reports-active': true,
        'application-identifier': 'PZYM8XX95Q.au.com.shiftyjelly.podcasts',
        'keychain-access-groups': ['PZYM8XX95Q.*', 'com.apple.token'],
        'com.apple.developer.siri': true,
        'com.apple.developer.applesignin': ['Default'],
        'com.apple.developer.carplay-audio': true,
        'com.apple.developer.team-identifier': 'PZYM8XX95Q',
        'com.apple.developer.playable-content': true,
        'com.apple.security.application-groups': [
          'group.au.com.shiftyjelly.pocketcasts',
          'group.com.pocketcasts.shareextension'
        ],
        'com.apple.developer.associated-domains': '*',
        'com.apple.developer.networking.wifi-info': true
      }
      m.capabilities = [
        'Access WiFi Information',
        'App Groups',
        'Associated Domains',
        'GameKit',
        'In-App Purchase',
        'Push Notifications',
        'Sign In with Apple',
        'SiriKit'
      ]
      m.checksum = 'f443be664d135cb423cee3280905451bb96bfdd9'
    end

    metadata.save!(validate: false)
  end

  def create_android_teardown(user) # rubocop:disable Metrics/MethodLength
    metadata = Metadatum.find_or_initialize_by(bundle_id: 'au.com.shiftyjelly.pocketcasts') do |m|
      m.user = the_user(user)
      m.platform = 'android'
      m.device = 'phone'
      m.name = 'Pocket Casts'
      m.release_version = '7.64'
      m.build_version = '9236'
      m.size = 26521079
      m.min_sdk_version = '23'
      m.target_sdk_version = '31'
      m.release_type = 'enterprise'
      m.url_schemes = ['content', 'feed', 'file', 'itpc', 'pcast', 'pktc', 'rss']
      m.activities = [
        'au.com.shiftyjelly.pocketcasts.ui.MainActivity',
        'au.com.shiftyjelly.pocketcasts.profile.sonos.SonosAppLinkActivity',
        'com.google.android.gms.oss.licenses.OssLicensesMenuActivity',
        'com.google.android.gms.oss.licenses.OssLicensesActivity',
        'au.com.shiftyjelly.pocketcasts.profile.cloud.AddFileActivity',
        'au.com.shiftyjelly.pocketcasts.account.AccountActivity',
        'au.com.shiftyjelly.pocketcasts.podcasts.view.share.ShareListCreateActivity',
        'au.com.shiftyjelly.pocketcasts.account.onboarding.OnboardingActivity',
        'au.com.shiftyjelly.pocketcasts.player.view.video.VideoActivity',
        'au.com.shiftyjelly.pocketcasts.player.view.bookmark.BookmarkActivity',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.playplaylist.config.ActivityConfigPlayPlaylist',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.controlplayback.config.ActivityConfigControlPlayback',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.querypodcasts.config.ActivityConfigQueryPodcasts',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.querypodcastepisodes.config.ActivityConfigQueryPodcastEpisodes',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.addtoupnext.config.ActivityConfigAddToUpNext',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.queryfilters.config.ActivityConfigQueryFilters',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.queryfilterepisodes.config.ActivityConfigQueryFilterEpisodes',
        'au.com.shiftyjelly.pocketcasts.taskerplugin.queryUpNext.config.ActivityConfigQueryUpNext',
        'au.com.shiftyjelly.pocketcasts.views.activity.WebViewActivity',
        'androidx.glance.appwidget.action.ActionTrampolineActivity',
        'androidx.glance.appwidget.action.InvisibleActionTrampolineActivity',
        'com.airbnb.android.showkase.ui.ShowkaseBrowserActivity',
        'androidx.car.app.CarAppPermissionActivity',
        'androidx.compose.ui.tooling.PreviewActivity',
        'com.google.android.gms.auth.api.signin.internal.SignInHubActivity',
        'com.google.android.gms.common.api.GoogleApiActivity',
        'com.android.billingclient.api.ProxyBillingActivity',
        'com.google.android.play.core.common.PlayCoreDialogWrapperActivity'
      ]
      m.services = [
        'androidx.core.widget.RemoteViewsCompatService',
        'androidx.glance.appwidget.GlanceRemoteViewsService',
        'androidx.room.MultiInstanceInvalidationService',
        'androidx.work.impl.background.systemalarm.SystemAlarmService',
        'androidx.work.impl.background.systemjob.SystemJobService',
        'androidx.work.impl.foreground.SystemForegroundService',
        'au.com.shiftyjelly.pocketcasts.PocketCastsWearListenerService',
        'au.com.shiftyjelly.pocketcasts.profile.accountmanager.PocketCastsAuthenticatorService',
        'au.com.shiftyjelly.pocketcasts.repositories.download.UpdateEpisodeDetailsJob',
        'au.com.shiftyjelly.pocketcasts.repositories.jobs.VersionMigrationsJob',
        'au.com.shiftyjelly.pocketcasts.repositories.playback.PlaybackService',
        'au.com.shiftyjelly.pocketcasts.repositories.refresh.RefreshPodcastsJob',
        'au.com.shiftyjelly.pocketcasts.repositories.sync.UpNextSyncJob',
        'com.google.android.datatransport.runtime.backends.TransportBackendDiscovery',
        'com.google.android.datatransport.runtime.scheduling.jobscheduling.JobInfoSchedulerService',
        'com.google.android.gms.auth.api.signin.RevocationBoundService',
        'com.google.android.gms.cast.framework.ReconnectionService',
        'com.google.android.gms.measurement.AppMeasurementJobService',
        'com.google.android.gms.measurement.AppMeasurementService',
        'com.google.firebase.components.ComponentDiscoveryService',
        'com.joaomgcd.taskerpluginlibrary.action.IntentServiceAction',
        'com.joaomgcd.taskerpluginlibrary.condition.IntentServiceCondition'
      ]

      m.permissions = [
        'android.permission.INTERNET',
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.WAKE_LOCK',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.RECEIVE_BOOT_COMPLETED',
        'android.permission.VIBRATE',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.BLUETOOTH',
        'android.permission.FOREGROUND_SERVICE',
        'android.permission.FOREGROUND_SERVICE_DATA_SYNC',
        'com.android.vending.CHECK_LICENSE',
        'com.android.vending.BILLING',
        'android.permission.SCHEDULE_EXACT_ALARM',
        'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK',
        'com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE',
        'au.com.shiftyjelly.pocketcasts.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
      ]

      m.features = [
        'android.hardware.bluetooth',
        'android.hardware.telephony'
      ]

      m.developer_certs = [
        {
          'scheme': 1,
          'verified': false,
          'certificates': [
            {
              'digest': 'sha1',
              'format': 'x509',
              'issuer': [
                ['C', 'AU'],
                ['ST', 'South Australia'],
                ['L', 'Adelaide'],
                ['O', 'Shifty Jelly'],
                ['OU', 'Shifty Jelly'],
                ['CN', 'Shifty Jelly']
              ],
              'length': 2048,
              'serial': { 'hex': '0x4d462786', 'number': '1296443270' },
              'subject': [
                ['C', 'AU'],
                ['ST', 'South Australia'],
                ['L', 'Adelaide'],
                ['O', 'Shifty Jelly'],
                ['OU', 'Shifty Jelly'],
                ['CN', 'Shifty Jelly']
              ],
              'version': 'v3',
              'algorithem': 'rsa',
              'created_at': '2011-01-31T03:07:50.000Z',
              'expired_at': '2038-06-18T03:07:50.000Z',
              'fingerprint': {
                'md5': 'c2:fe:0d:a3:8f:cd:86:83:9b:85:da:08:37:e6:3c:08',
                'sha1': '26:5b:fd:a6:99:2d:75:d4:55:bc:74:dd:43:f9:ac:e8:3e:fa:e7:e5',
                'sha256': 'ce:08:25:f4:ca:78:56:76:d9:0d:3a:f6:0f:54:fe:43:b8:42:7a:fe:9e:1b:b6:77:ad:d7:58:da:c1:29:18:20'
              }
            }
          ]
        },
        {
          'scheme': 2,
          'verified': false,
          'certificates': [
            {
              'digest': 'sha1',
              'format': 'x509',
              'issuer': [
                ['C', 'AU'],
                ['ST', 'South Australia'],
                ['L', 'Adelaide'],
                ['O', 'Shifty Jelly'],
                ['OU', 'Shifty Jelly'],
                ['CN', 'Shifty Jelly']
              ],
              'length': 2048,
              'serial': { 'hex': '0x4d462786', 'number': '1296443270' },
              'subject': [
                ['C', 'AU'],
                ['ST', 'South Australia'],
                ['L', 'Adelaide'],
                ['O', 'Shifty Jelly'],
                ['OU', 'Shifty Jelly'],
                ['CN', 'Shifty Jelly']
              ],
              'version': 'v3',
              'algorithem': 'rsa',
              'created_at': '2011-01-31T03:07:50.000Z',
              'expired_at': '2038-06-18T03:07:50.000Z',
              'fingerprint': {
                'md5': 'c2:fe:0d:a3:8f:cd:86:83:9b:85:da:08:37:e6:3c:08',
                'sha1': '26:5b:fd:a6:99:2d:75:d4:55:bc:74:dd:43:f9:ac:e8:3e:fa:e7:e5',
                'sha256': 'ce:08:25:f4:ca:78:56:76:d9:0d:3a:f6:0f:54:fe:43:b8:42:7a:fe:9e:1b:b6:77:ad:d7:58:da:c1:29:18:20'
              }
            }
          ]
        },
        {
          'scheme': 3,
          'verified': false,
          'certificates': [
            {
              'digest': 'sha1',
              'format': 'x509',
              'issuer': [
                ['C', 'AU'],
                ['ST', 'South Australia'],
                ['L', 'Adelaide'],
                ['O', 'Shifty Jelly'],
                ['OU', 'Shifty Jelly'],
                ['CN', 'Shifty Jelly']
              ],
              'length': 2048,
              'serial': { 'hex': '0x4d462786', 'number': '1296443270' },
              'subject': [
                ['C', 'AU'],
                ['ST', 'South Australia'],
                ['L', 'Adelaide'],
                ['O', 'Shifty Jelly'],
                ['OU', 'Shifty Jelly'],
                ['CN', 'Shifty Jelly']
              ],
              'version': 'v3',
              'algorithem': 'rsa',
              'created_at': '2011-01-31T03:07:50.000Z',
              'expired_at': '2038-06-18T03:07:50.000Z',
              'fingerprint': {
                'md5': 'c2:fe:0d:a3:8f:cd:86:83:9b:85:da:08:37:e6:3c:08',
                'sha1': '26:5b:fd:a6:99:2d:75:d4:55:bc:74:dd:43:f9:ac:e8:3e:fa:e7:e5',
                'sha256': 'ce:08:25:f4:ca:78:56:76:d9:0d:3a:f6:0f:54:fe:43:b8:42:7a:fe:9e:1b:b6:77:ad:d7:58:da:c1:29:18:20'
              }
            }
          ]
        }
      ]

      m.checksum = '42166b35c37210fa8d9dd932df4ef752a1ff0f4b'
    end
    metadata.save!(validate: false)
  end

  def stardford_app(user) # rubocop:disable Metrics/MethodLength
    app_name = I18n.t('demo.app_name1')
    app_bundle_id = 'com.zealot.app-demo'
    schemes = [
      {
        name: I18n.t('settings.preset_schemes.beta'),
        channels: [
          {
            name: 'Android',
            slug: 'appBetaAndroid'
          },
          {
            name: 'iOS',
            slug: 'appBetaiPhone'
          }
        ]
      },
      {
        name: I18n.t('settings.preset_schemes.adhoc'),
        channels: [
          {
            name: 'Android',
            slug: 'appAdhocAndroid'
          },
          {
            name: 'iOS',
            slug: 'appAdhociPhone'
          }
        ]
      },
      {
        name: I18n.t('settings.preset_schemes.production'),
        channels: [
          {
            name: 'Android',
            slug: 'appProductionAndroid'
          },
          {
            name: 'iOS',
            slug: 'appProductioniPhone'
          }
        ]
      }
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

    schemes.each do |scheme_data|
      scheme = app.schemes.find_or_create_by name: scheme_data[:name]
      scheme_data[:channels].each do |channel_data|
        channel_data[:device_type] = channel_data[:name].downcase.to_sym
        channel = scheme.channels.find_or_create_by channel_data
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

    app
  end

  def android_channels_app(user)
    app_name = I18n.t('demo.app_name2')
    app_bundle_id = 'com.zealot.android.app-demo'
    schemes = [ I18n.t('settings.preset_schemes.production') ]
    channels = I18n.t('demo.android_channels', locale: :en).values
    changelog = "bump 0.1.0\nfix: xxx\nfeat: xxx done"

    app = create_app(app_name, user)

    schemes.each do |scheme_name|
      scheme = app.schemes.find_or_create_by name: scheme_name
      channels.each_with_index do |channel_name, i|
        slug = CGI.escape("android#{channel_name.capitalize}")
        channel = scheme.channels.find_or_create_by name: channel_name,
                                                    device_type: :android,
                                                    slug: slug
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

    app
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
    app = App.find_or_initialize_by(name:)
    return app unless app.new_record?

    app.save!
    app.create_owner(the_user(user))
    app
  end

  def the_user(user)
    user.is_a?(Array) ? user.first : user
  end
end
