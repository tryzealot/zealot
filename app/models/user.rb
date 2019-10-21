class User < ApplicationRecord
  include UserRoles

  devise :database_authenticatable, :registerable, :confirmable,
         :rememberable, :trackable, :validatable, :recoverable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum role: [:user, :developer, :admin]

  has_and_belongs_to_many :apps
  has_many :user_providers

  validates :username, presence: true
  validates :email, presence: true

  after_initialize :set_default_role, if: :new_record?
  after_initialize :generate_user_token, if: :new_record?

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |t|
      t.name = auth.info.name
      t.password = Devise.friendly_token[0, 20]
      t.confirmed_at = Time.now
    end
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def generate_user_token
    self.token = Digest::MD5.hexdigest(email + '!@#')
  end
end
