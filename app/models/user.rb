class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles

  before_create :generate_user_key

  def has_role?(name)
    self.roles.where(name: name).length > 0
  end

  private
    def generate_user_key
      self.key = Digest::MD5.hexdigest(self.email + "!@#")
      self.secret = Digest::SHA1.base64digest(key)[0..6]
    end
end
