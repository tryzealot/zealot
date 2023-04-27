# frozen_string_literal: true

class User < ApplicationRecord
  extend UserOmniauth
  devise :database_authenticatable, :registerable, :confirmable,
         :rememberable, :trackable, :validatable, :recoverable,
         :omniauthable, omniauth_providers: %i[feishu gitlab google_oauth2 ldap openid_connect]

  include UserRoles
  enum role: %i[user developer admin]

  has_and_belongs_to_many :apps, dependent: :destroy
  has_many :providers, dependent: :destroy, class_name: 'UserProvider'

  validates :username, presence: true
  validates :email, presence: true

  after_initialize :set_default_role, if: :new_record?
  after_initialize :generate_user_token, if: :new_record?

  private

  def set_default_role
    self.role ||= Setting.preset_role || :user
  end

  def generate_user_token
    self.token = Digest::MD5.hexdigest(email + '!@#')
  end
end
