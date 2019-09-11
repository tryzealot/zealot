class ChannelSerializer < ApplicationSerializer
  attributes :id, :name, :device_type, :bundle_id, :slug, :git_url
end