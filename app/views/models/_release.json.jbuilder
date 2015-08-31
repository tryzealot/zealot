json.(release,
  :id, :version, :channel, :filesize, :release_version,
  :build_version, :branch, :last_commit, :ci_url, :changelog)

url = if release.app.device_type.downcase == 'android'
  api_app_download_url(release.id)
else
  api_app_install_url(release.app.slug, release.id)
end

json.set! :install_url, url

json.(release, :created_at, :updated_at)