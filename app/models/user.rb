class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles
  has_many :permissions, through: :roles

  before_create :generate_user_key

  validates :name, presence: true, on: :web

  def current_roles
    roles.all.map {|r| r.name }.join('/')
  end

  def update_roles(ids)
    ids.each do |role_id|
      next if role_id.blank?
      next if roles.where(id: role_id).exists?

      roles << Role.find(role_id)
    end
  end

  def roles?(*values)
    roles.where(value: values).exists?
  end

  private

  def generate_user_key
    self.key = Digest::MD5.hexdigest(email + '!@#')
    self.secret = Digest::SHA1.base64digest(key)[0..6]
  end
end
