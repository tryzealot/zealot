# frozen_string_literal: true

class UserProvider < ApplicationRecord
  belongs_to :user

  def self.from_omniauth(auth)
    credentials = auth.credentials
    provider = find_or_create_by(name: auth.provider, uid: auth.uid)
    provider.update!(
      token: credentials.token,
      expires: credentials.expires,
      expires_at: credentials.expires_at,
      refresh_token: credentials.refresh_token
    )
  end

  def update_omniauth(credentials)
    update(
      token: credentials.token,
      expires: credentials.expires,
      expires_at: credentials.expires_at,
      refresh_token: credentials.refresh_token
    )
  end
end
