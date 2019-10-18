class User < ApplicationRecord
  include UserRoles

  devise :database_authenticatable, :registerable, :confirmable,
         :rememberable, :trackable, :validatable, :recoverable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_and_belongs_to_many :apps
  has_and_belongs_to_many :roles
  has_many :permissions, through: :roles
  has_many :user_providers

  validates :username, presence: true

  before_create :generate_user_token

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |t|
      t.name = auth.info.name
      t.password = Devise.friendly_token[0, 20]
      t.confirmed_at = Time.now

      t.roles << Role.default_role
      UserProvider.from_omniauth(auth, t)
    end
  end

  def update_roles(ids)
    ids.each do |role_id|
      next if role_id.blank?
      next if roles.where(id: role_id).exists?

      roles << Role.find(role_id)
    end
  end

  private

  def generate_user_token
    self.token = Digest::MD5.hexdigest(email + '!@#')
  end
end
