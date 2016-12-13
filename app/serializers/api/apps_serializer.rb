class Api::AppsSerializer < Api::BaseSerializer
  attributes :id, :name, :identifier, :device_type, :slug, :release_version, :build_version, :icon_url, :install_url,
             :changelog, :commits, :created_at, :updated_at

  def install_url
    if object.device_type.casecmp('android').zero?
      api_v2_apps_download_url(release.version)
    else
      'itms-services://?action=download-manifest&url=' + api_v2_apps_install_url(
        object.releases.last.version.to_s,
        protocol: Rails.env.development? ? 'http' : 'https'
      )
    end
  end

  def changelog
    data = []
    commits.each_with_index do |item, i|
      data << "#{i + 1}.#{item[:message]}"
    end

    data.join("\n")
  end

  def commits
    object.changelog(
      since_release_version: @instance_options[:release_version],
      since_build_version: @instance_options[:build_version]
    )
  end
end
