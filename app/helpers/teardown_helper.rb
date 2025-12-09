# frozen_string_literal: true

module TeardownHelper # rubocop:disable Metrics/ModuleLength
  def teardown_owner?(metadata)
    return false unless current_user
    return true if current_user.manage?

    metadata.user == current_user
  end

  def android_v1_signature?(certificates)
    !certificates.any? { |cert| cert.key?('scheme') }
  end

  def certificate_name(dn)
    dn.map { |k, v| "#{k}=#{v}" }.join(', ')
  end

  def expired_date_tips(expired_date, colorful: true, prefix: nil)
    time = Time.parse(expired_date)
    duration = ActiveSupport::Duration.build(time - Time.now)
    time_in_words = distance_of_time_in_words(time, Time.now)

    style_name = 'text-success'
    message = t('teardowns.show.expired_in', time: time_in_words)

    if duration.value < 0
      style_name = 'text-error'
      message = t('teardowns.show.already_expired', time: time_in_words)
    elsif duration.value == 0
      style_name = 'text-error'
      message = t('teardowns.show.expired')
    else
      style_name = (duration.value <= 3.months.to_i) ? 'text-warning' : 'text-success'
    end

    tooltip = ['d-tooltip', 'd-tooltip-right']

    options = {
      class: colorful ? tooltip.concat([style_name, 'font-bold']) : tooltip,
      data: { tip: l(Time.zone.parse(expired_date), format: :nice) }
    }

    content_tag(:span, "#{prefix}#{message}", options)
  end

  def android_version_info(api_version)
    info = ANDROID_APIS[api_version.to_sym]
    api = "API #{api_version}"
    return api unless info

    version = info[:version]
    codename = info[:codename]

    "#{version} (#{codename}, #{api})"
  end

  def macos_version_info(version)
    info = MACOS_VERSIONS[version.to_sym] || MACOS_VERSIONS[version.split('.')[0]&.to_sym]
    return version unless info

    os = "#{info[:name]} #{version}"
    codename = info[:codename]

    "#{os} (#{codename})"
  end

  # Source: https://apilevels.com/#footnotes
  ANDROID_APIS = {
    "35": {
      "version": "Android 15",
      "url": "https://developer.android.com/about/versions/15",
      "version_code": "VANILLA_ICE_CREAM",
      "codename": "Vanilla Ice Cream",
      "cumulative": "-",
      "development": true,
      "year": "TBD"
    },
    "34": {
      "version": "Android 14",
      "url": "https://developer.android.com/about/versions/14",
      "version_code": "UPSIDE_DOWN_CAKE",
      "codename": "Upside Down Cake",
      "cumulative": "16.3",
      "year": "2023"
    },
    "33": {
      "version": "Android 13",
      "url": "https://developer.android.com/about/versions/13",
      "version_code": "TIRAMISU",
      "codename": "Tiramisu",
      "cumulative": "42.5",
      "year": "2022"
    },
    "32": {
      "version": "Android 12L",
      "url": "https://developer.android.com/about/versions/12",
      "version_code": "S_V2",
      "codename": "Snow Cone",
      "cumulative": "59.5",
      "year": "2021"
    },
    "31": {
      "version": "Android 12",
      "url": "https://developer.android.com/about/versions/12",
      "version_code": "S",
      "codename": "Snow Cone",
      "cumulative": "59.5",
      "year": "2021"
    },
    "30": {
      "version": "Android 11",
      "url": "https://developer.android.com/about/versions/11",
      "version_code": "R",
      "codename": "Red Velvet Cake",
      "cumulative": "75.7",
      "year": "2020"
    },
    "29": {
      "version": "Android 10",
      "url": "https://developer.android.com/about/versions/10",
      "version_code": "Q",
      "codename": "Quince Tart",
      "cumulative": "84.5",
      "year": "2019"
    },
    "28": {
      "version": "Android 9",
      "url": "https://developer.android.com/about/versions/pie",
      "version_code": "P",
      "codename": "Pie",
      "cumulative": "90.2",
      "year": "2018"
    },
    "27": {
      "version": "Android 8.1",
      "url": "https://developer.android.com/about/versions/oreo",
      "version_code": "O_MR1",
      "codename": "Oreo",
      "cumulative": "92.1",
      "year": "2017"
    },
    "26": {
      "version": "Android 8.0",
      "url": "https://developer.android.com/about/versions/oreo",
      "version_code": "O",
      "codename": "Oreo",
      "cumulative": "95.1",
      "year": "2017"
    },
    "25": {
      "version": "Android 7.1",
      "url": "https://developer.android.com/about/versions/nougat",
      "version_code": "N_MR1",
      "codename": "Nougat",
      "cumulative": "95.6",
      "year": "2016"
    },
    "24": {
      "version": "Android 7.0",
      "url": "https://developer.android.com/about/versions/nougat",
      "version_code": "N",
      "codename": "Nougat",
      "cumulative": "97.0",
      "year": "2016"
    },
    "23": {
      "version": "Android 6",
      "url": "https://developer.android.com/about/versions/marshmallow",
      "version_code": "M",
      "codename": "Marshmallow",
      "cumulative": "98.4",
      "year": "2015"
    },
    "22": {
      "version": "Android 5.1",
      "url": "https://developer.android.com/about/versions/lollipop",
      "version_code": "LOLLIPOP_MR1",
      "codename": "Lollipop",
      "cumulative": "99.2",
      "year": "2014"
    },
    "21": {
      "version": "Android 5.0",
      "url": "https://developer.android.com/about/versions/lollipop",
      "version_code": "LOLLIPOP",
      "codename": "Lollipop",
      "cumulative": "99.5",
      "year": "2014"
    },
    "20": {
      "version": "Android 4.4W",
      "url": "https://developer.android.com/about/versions",
      "version_code": "KITKAT_WATCH",
      "codename": "KitKat",
      "cumulative": "99.8",
      "year": "2013"
    },
    "19": {
      "version": "Android 4.4",
      "url": "https://developer.android.com/about/versions",
      "version_code": "KITKAT",
      "codename": "KitKat",
      "cumulative": "99.8",
      "year": "2013"
    },
    "18": {
      "version": "Android 4.3",
      "url": "https://developer.android.com/about/versions",
      "version_code": "JELLY_BEAN_MR2",
      "codename": "Jelly Bean",
      "cumulative": "99.8",
      "year": "2012"
    },
    "17": {
      "version": "Android 4.2",
      "url": "https://developer.android.com/about/versions",
      "version_code": "JELLY_BEAN_MR1",
      "codename": "Jelly Bean",
      "cumulative": "99.8",
      "year": "2012"
    },
    "16": {
      "version": "Android 4.1",
      "url": "https://developer.android.com/about/versions",
      "version_code": "JELLY_BEAN",
      "codename": "Jelly Bean",
      "cumulative": "99.8",
      "year": "2012"
    },
    "15": {
      "version": "Android 4.0.3 – 4.0.4",
      "url": "https://developer.android.com/about/versions",
      "version_code": "ICE_CREAM_SANDWICH_MR1",
      "codename": "Ice Cream Sandwich",
      "cumulative": "99.8",
      "year": "2011"
    },
    "14": {
      "version": "Android 4.0.1 – 4.0.2",
      "url": "https://developer.android.com/about/versions",
      "version_code": "ICE_CREAM_SANDWICH",
      "codename": "Ice Cream Sandwich",
      "cumulative": "99.8",
      "year": "2011"
    },
    "13": {
      "version": "Android 3.2",
      "url": "https://developer.android.com/about/versions",
      "version_code": "HONEYCOMB_MR2",
      "codename": "Honeycomb",
      "cumulative": "No data",
      "year": "2011"
    },
    "12": {
      "version": "Android 3.1",
      "url": "https://developer.android.com/about/versions",
      "version_code": "HONEYCOMB_MR1",
      "codename": "Honeycomb",
      "cumulative": "No data",
      "year": "2011"
    },
    "11": {
      "version": "Android 3.0",
      "url": "https://developer.android.com/about/versions",
      "version_code": "HONEYCOMB",
      "codename": "Honeycomb",
      "cumulative": "No data",
      "year": "2011"
    },
    "10": {
      "version": "Android 2.3.3 – 2.3.7",
      "url": "https://developer.android.com/about/versions",
      "version_code": "GINGERBREAD_MR1",
      "codename": "Gingerbread",
      "cumulative": "No data",
      "year": "2010"
    },
    "9": {
      "version": "Android 2.3.0 – 2.3.2",
      "url": "https://developer.android.com/about/versions",
      "version_code": "GINGERBREAD",
      "codename": "Gingerbread",
      "cumulative": "No data",
      "year": "2010"
    },
    "8": {
      "version": "Android 2.2",
      "url": "https://developer.android.com/about/versions",
      "version_code": "FROYO",
      "codename": "Froyo",
      "cumulative": "No data",
      "year": "2010"
    },
    "7": {
      "version": "Android 2.1",
      "url": "https://developer.android.com/about/versions",
      "version_code": "ECLAIR_MR1",
      "codename": "Eclair",
      "cumulative": "No data",
      "year": "2010"
    },
    "6": {
      "version": "Android 2.0.1",
      "url": "https://developer.android.com/about/versions",
      "version_code": "ECLAIR_0_1",
      "codename": "Eclair",
      "cumulative": "No data",
      "year": "2009"
    },
    "5": {
      "version": "Android 2.0",
      "url": "https://developer.android.com/about/versions",
      "version_code": "ECLAIR",
      "codename": "Eclair",
      "cumulative": "No data",
      "year": "2009"
    },
    "4": {
      "version": "Android 1.6",
      "url": "https://developer.android.com/about/versions",
      "version_code": "DONUT",
      "codename": "Donut",
      "cumulative": "No data",
      "year": "2009"
    },
    "3": {
      "version": "Android 1.5",
      "url": "https://developer.android.com/about/versions",
      "version_code": "CUPCAKE",
      "codename": "Cupcake",
      "cumulative": "No data",
      "year": "2009"
    },
    "2": {
      "version": "Android 1.1",
      "url": "https://developer.android.com/about/versions",
      "version_code": "BASE_1_1",
      "codename": "Base",
      "cumulative": "No data",
      "year": "2009"
    },
    "1": {
      "version": "Android 1.0",
      "url": "https://developer.android.com/about/versions",
      "version_code": "BASE",
      "codename": "Base",
      "cumulative": "No data",
      "year": "2008"
    }
  }

  MACOS_VERSIONS = {
    "14": {
      "name": "macOS",
      "codename": "Sonoma",
      "year": "2023"
    },
    "13": {
      "name": "macOS",
      "codename": "Ventura",
      "year": "2022"
    },
    "12": {
      "name": "macOS",
      "codename": "Monterey",
      "year": "2021"
    },
    "11": {
      "name": "macOS",
      "codename": "Big Sur",
      "year": "2020"
    },
    "10.15": {
      "name": "macOS",
      "codename": "Catalina",
      "year": "2019"
    },
    "10.14": {
      "name": "macOS 14",
      "codename": "Mojave",
      "year": "2018"
    },
    "10.13": {
      "name": "macOS 14",
      "codename": "High Sierra",
      "year": "2017"
    },
    "10.12": {
      "name": "macOS 14",
      "codename": "Sierra",
      "year": "2016"
    },
    "10.11": {
      "name": "OS X",
      "codename": "El Capitan",
      "year": "2015"
    },
    "10.10": {
      "name": "OS X",
      "codename": "Yosemite",
      "year": "2014"
    },
    "10.9": {
      "name": "OS X",
      "codename": "Mavericks",
      "year": "2013"
    }
  }
end
