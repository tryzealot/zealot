json.(release,
  :id, :version, :channel, :release_version,
  :build_version, :branch, :last_commit, :ci_url, :changelog)

json.filesize number_to_human_size(release.filesize)

json.set! :changelog, release.plain_text_changelog

json.set! :install_url, if release.app.device_type.casecmp('android').zero?
  api_app_download_url(release.id)
else
  'itms-services://?action=download-manifest&url=' + api_app_install_url(
    release.app.slug,
    release.id,
    protocol: Rails.env.development? ? 'http' : 'https'
  )
end

json.(release, :created_at, :updated_at)