latest = @app.releases.latest

json.partial! 'models/app', app: @app
json.latest do
  json.partial! 'models/release', release: latest
end if latest
json.versions @releases do |release|
  json.partial! 'models/release', release: release
end unless @releases.blank?
