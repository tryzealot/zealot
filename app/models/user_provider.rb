# frozen_string_literal: true

class UserProvider < ApplicationRecord
  belongs_to :user

  def self.initialize_from_omniauth(auth)
    UserProvider.where(name: auth.provider, uid: auth.uid).first_or_initialize do |provider|
      credentials = auth.credentials

      provider.token = credentials.token
      provider.expires = credentials.expires
      provider.expires_at = credentials.expires_at
      provider.refresh_token = credentials.refresh_token
    end
  end

  def self.create_from_omniauth(auth, user)
    UserProvider.where(name: auth.provider, uid: auth.uid).first_or_create do |provider|
      credentials = auth.credentials

      provider.user = user
      provider.token = credentials.token
      provider.expires = credentials.expires
      provider.expires_at = credentials.expires_at
      provider.refresh_token = credentials.refresh_token
    end
  end
end
