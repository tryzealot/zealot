class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles
  has_many :permissions, through: :roles
  has_many :apps

  before_create :generate_user_key

  def role?(name)
    roles.where(name: name).empty?
  end

  private

  def generate_user_key
    self.key = Digest::MD5.hexdigest(email + '!@#')
    self.secret = Digest::SHA1.base64digest(key)[0..6]
  end
end
