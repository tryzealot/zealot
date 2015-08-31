json.array! @releases, partial: 'models/release', as: :release
# json.array! @releases do |release|
#   json.(app, :id, :slug, :name, :identifier, :device_type)
#   json.set! :count, app.releases.count
#   json.(app, :created_at, :updated_at)
# end