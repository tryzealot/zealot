class Api::AppsSerializer < Api::BaseSerializer
  attributes :id, :name, :identifier, :device_type, :slug, :version, :release_version, :build_version, :icon_url, :install_url,
             :changelog, :commits, :created_at, :updated_at

  def install_url
    if object.device_type.casecmp('android').zero?
      api_v2_apps_download_url(object.slug, release_version)
    else
      'itms-services://?action=download-manifest&url=' + api_v2_apps_install_url(
        object.slug,
        release_version,
        protocol: Rails.env.development? ? 'http' : 'https'
      )
    end
  end

  def release_version
    @instance_options[:release_version] ? @instance_options[:release_version] : object.releases.last.try(:[], :version)
  end

  def changelog
    data = []
    commits.each_with_index do |item, i|
      data << "#{i + 1}.#{item[:message]}"
    end

    changelog = data.join("\n")
    changelog.blank? ? "没有更新日志的原因：\n1.开发者很懒没有留下更新日志😂\n2.有不可抗拒的因素造成日志丢失👽" : changelog
  end

  def commits
    object.changelog(
      since_release_version: @instance_options[:release_version],
      since_build_version: @instance_options[:build_version]
    )
  end
end
