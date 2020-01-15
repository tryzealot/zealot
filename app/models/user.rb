# frozen_string_literal: true

class User < ApplicationRecord
  include UserRoles
  extend UserOmniauth

  devise :database_authenticatable, :registerable, :confirmable,
         :rememberable, :trackable, :validatable, :recoverable,
         :omniauthable, omniauth_providers: %i[google_oauth2 ldap]

  enum role: %i[user developer admin]

  has_and_belongs_to_many :apps
  has_many :user_providers, dependent: :destroy

  validates :username, presence: true
  validates :email, presence: true

  after_initialize :set_default_role, if: :new_record?
  after_initialize :generate_user_token, if: :new_record?

  private

  def set_default_role
    self.role ||= :user
  end

  def generate_user_token
    self.token = Digest::MD5.hexdigest(email + '!@#')
  end
end
