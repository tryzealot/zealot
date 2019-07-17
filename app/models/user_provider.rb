class UserProvider < ApplicationRecord
  belongs_to :user

  def self.from_omniauth(auth, user)
    UserProvider.where(name: auth.provider, uid: auth.uid).first_or_create do |provider|
      provider.user = user
      provider.token = auth.credentials.token
      provider.expires = auth.credentials.expires
      provider.expires_at = auth.credentials.expires_at
      provider.refresh_token = auth.credentials.refresh_token
    end
  end
end
