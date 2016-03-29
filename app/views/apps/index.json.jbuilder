# json.array! @apps, partial: 'models/app', as: :app
json.array! @apps do |app|
  json.(app, :id, :slug, :name, :identifier, :device_type, :password)
  json.set! :count, app.releases.count
  json.(app, :created_at, :updated_at)
end