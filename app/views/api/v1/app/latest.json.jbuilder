json.partial! "models/app", app: @app

latest = @app.releases.latest

json.version latest.version
json.release_version latest.release_version
json.build_version latest.build_version
json.changelog latest.changelog
json.branch latest.branch
json.last_commit latest.last_commit
json.ci_url latest.ci_url
json.channel latest.channel
json.filesize number_to_human_size(latest.filesize)

install_url = if @app.device_type.downcase == 'android'
  root_url + latest.file.url
else
  url = "itms-services://?action=download-manifest&url=" + url_for(protocol: Rails.env.development? ? 'http' : 'https', controller: 'app', action: 'install_url', slug: @app.slug, release_id: latest.id, only_path: false)
end

json.install_url install_url
