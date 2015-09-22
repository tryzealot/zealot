json.partial! "models/app", app: @app

json.versions @app.releases.order(created_at: :desc).limit(10) do |release|
  json.partial! "models/release", release: release
end


# @app.releases, :version, :created_at

# json.set! :versions, "models/release", releases: @app.releases.order(created_at: :desc).limit(10)