class Api::AppsSerializer < Api::BaseSerializer
  attributes :id, :name, :identifier, :device_type, :slug, :version, :release_version, :build_version, :icon_url, :install_url,
             :changelog, :commits, :created_at, :updated_at

  def changelog
    if commits.empty?
      Release.new.empty_text_changelog
    else
      commits.map { |v| "- #{v['message']}" }.join("\n")
    end
  end

  def commits
    object.changelog(
      since_release_version: @instance_options[:release_version],
      since_build_version: @instance_options[:build_version]
    )
  end
end
