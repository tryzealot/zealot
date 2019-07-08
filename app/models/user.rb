class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles
  has_many :permissions, through: :roles

  before_create :generate_user_key
  before_create :generate_activation_token

  validates :name, presence: true, on: :web

  def active(params)
    params[:activation_token] = nil
    params[:actived_at] = Time.now.utc

    update(params)
  end

  def current_roles
    roles.all.map(&:name).join('/')
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

  def generate_activation_token
    if activation_token# && !activation_period_expired?
      activation_token
    else
      self.activation_token = Digest::MD5.hexdigest("#{key}:#{secret}")
      self.activation_sent_at = Time.now.utc
    end
  end
end
