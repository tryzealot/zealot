json.partial! "models/app", app: @app

latest = @app.releases.latest

if latest
  json.version latest.version
  json.release_version latest.release_version
  json.build_version latest.build_version
  json.changelog latest.plain_text_changelog
  json.branch latest.branch
  json.last_commit latest.last_commit
  json.ci_url latest.ci_url
  json.channel latest.channel
  json.filesize number_to_human_size(latest.filesize)

  install_url =
    if @app.device_type.casecmp('android').zero?
      root_url + latest.file.url
    else
      app_install_url = url_for(
        protocol: 'https',
        controller: 'app',
        action: 'install_url',
        slug: @app.slug,
        release_id: latest.id,
        only_path: false
      )

      'itms-services://?action=download-manifest&url=' + app_install_url
    end

  json.install_url install_url
end
