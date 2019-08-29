class Api::AppsSerializer < ApplicationSerializer
  attributes :id, :name, :created_at, :updated_at

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
