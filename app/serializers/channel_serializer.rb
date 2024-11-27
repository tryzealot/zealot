# frozen_string_literal: true

class ChannelSerializer < ApplicationSerializer
  attributes :id, :slug, :name, :device_type, :bundle_id, :git_url, :has_password, 
             :key, :download_filename_type

  def has_password
    object.password.present?
  end
end
