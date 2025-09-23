# frozen_string_literal: true

PROVIDERS = %i[feishu gitlab google_oauth2 ldap openid_connect github gitea].freeze

class User < ApplicationRecord
  include UserSettings
  include UserRoles

  extend UserOmniauth
  devise :database_authenticatable, :registerable, :confirmable,
         :rememberable, :trackable, :validatable, :recoverable, :lockable,
         :omniauthable, omniauth_providers: PROVIDERS

  enum :role, %i[member developer admin]
  enum :locale, enum_roles
  enum :appearance, enum_appearances
  enum :timezone, enum_timezones

  has_and_belongs_to_many :apps, dependent: :destroy
  has_many :collaborators, dependent: :destroy
  has_many :metadatum, dependent: :destroy
  has_many :providers, dependent: :destroy, class_name: 'UserProvider'

  scope :avaiables, -> (id) { where.not(id: id) }

  validates :username, presence: true
  validates :email, presence: true

  after_initialize :set_default_role, if: :new_record?
  after_initialize :set_user_default_settings, if: :new_record?
  after_initialize :generate_user_token, if: :new_record?

  def create_app(**params)
    role_params = params.delete(:roles) || {}
    owner = params.delete(:owner) || false
    role = params.delete(:role) || Collaborator.roles[:member]

    ActiveRecord::Base.transaction do
      app = App.create(params)

      role_params[:user] = self
      role_params[:app] = app
      if owner
        role_params[:role] = Collaborator.roles[:admin]
        role_params[:owner] = true
      else
        role_params[:role] = role
        role_params[:owner] = false
      end

      Collaborator.create(role_params)

      app
    end
  end

  private

  def set_default_role
    self.role ||= Setting.preset_role || :member
  end

  def set_user_default_settings
    self.locale ||= Setting.site_locale
    self.appearance ||= Setting.site_appearance
    self.timezone ||= Setting.site_timezone
  end

  def generate_user_token
    self.token = Digest::MD5.hexdigest(SecureRandom.uuid)
  end
end
