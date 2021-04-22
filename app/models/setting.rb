# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { 'v1' }

  DEFAULT_SITE_HTTPS = Rails.env.production? || ENV['ZEALOT_USE_HTTPS'].present?
  DEFAULT_SITE_DOMAIN = DEFAULT_SITE_HTTPS ? 'localhost' : "localhost:#{ENV['ZEALOT_PORT'] || 3000}"
  DEFAULT_SCHEMES = [
    I18n.t('settings.default_schemes.beta'),
    I18n.t('settings.default_schemes.adhoc'),
    I18n.t('settings.default_schemes.production'),
  ]

  class << self
    def site_configs
      group_configs.each_with_object({}) do |(scope, items), obj|
        obj[scope] = items.each_with_object({}) do |item, inner|
          key = item[:key]
          value = Setting.send(key.to_sym)
          inner[key] = {
            value: value,
            readonly: item[:readonly]
          }
        end
      end
    end

    def find_or_default(var:)
      find_by(var: var) || new(var: var)
    end

    def group_configs
      defined_fields.select { |v| v[:options][:display] == true }.group_by { |v| v[:scope] || :misc }
    end

    def protocol
      site_https ? 'https://' : 'http://'
    end

    def url_options
      {
        host: site_domain,
        protocol: protocol,
        trailing_slash: false
      }
    end
  end

  # 系统配置
  scope :general do
    field :site_title, default: 'Zealot', type: :string, display: true,
                       validates: { presence: true, length: { in: 3..16 } }
    field :site_domain, default: (ENV['ZEALOT_DOMAIN'] || DEFAULT_SITE_DOMAIN), type: :string, readonly: true, display: true
    field :site_https, default: DEFAULT_SITE_HTTPS, type: :boolean, readonly: true, display: true

    field :admin_email, default: (ENV['ZEALOT_ADMIN_EMAIL'] || 'admin@zealot.com'), type: :string, readonly: true
    field :admin_password, default: (ENV['ZEALOT_ADMIN_PASSWORD'] || 'ze@l0t'), type: :string, readonly: true
  end

  # 预值
  scope :presets do
    field :default_schemes, default: DEFAULT_SCHEMES, type: :array, display: true
    field :default_role, default: 'user', type: :string, display: true,
                         validates: { presence: true, inclusion: { in: UserRoles::ROLE_NAMES.keys.map(&:to_s) } }
  end

  # 模式开关
  scope :switch_mode do
    field :registrations_mode, default: (ENV['ZEALOT_REGISTER_ENABLED'] || 'true'), type: :boolean, display: true
    field :guest_mode, default: (ENV['ZEALOT_GUEST_MODE'] || 'false'), type: :boolean, readonly: true, display: true
    field :demo_mode, default: (ENV['ZEALOT_DEMO_MODE'] || 'false'), type: :boolean, readonly: true, display: true
  end

  # 上传文件保留策略
  scope :limits do
    field :keep_uploads, default: (ENV['ZEALOT_KEEP_UPLOADS'] || 'true'), type: :boolean, readonly: true
  end

  # 第三方登录
  scope :third_party_auth do
    field :feishu, type: :hash, display: true, default: {
      enabled: ENV['FEISHU_ENABLED'] || false,
      app_id: ENV['FEISHU_APP_ID'],
      app_secret: ENV['FEISHU_APP_SECRET'],
    }

    field :gitlab, type: :hash, display: true, default: {
      enabled: ENV['GITLAB_ENABLED'] || false,
      site: ENV['GITLAB_SITE'] || 'https://gitlab.com/api/v4',
      scope: ENV['GITLAB_SCOPE'] || 'read_user',
      app_id: ENV['GITLAB_APP_ID'],
      secret: ENV['GITLAB_SECRET'],
    }

    field :google_oauth, type: :hash, display: true, default: {
      enabled: ENV['GOOGLE_OAUTH_ENABLED'] || false,
      client_id: ENV['GOOGLE_CLIENT_ID'],
      secret: ENV['GOOGLE_SECRET'],
    }

    field :ldap, type: :hash, display: true, default: {
      enabled: ENV['LDAP_ENABLED'] || false,
      host: ENV['LDAP_HOST'],
      port: ENV['LDAP_PORT'] || '389',
      encryption: ENV['LDAP_METHOD'] || ENV['LDAP_ENCRYPTION'] || 'plain', # LDAP_METHOD will be abandon in the future
      bind_dn: ENV['LDAP_BIND_DN'],
      password: ENV['LDAP_PASSWORD'],
      base: ENV['LDAP_BASE'],
      uid: ENV['LDAP_UID'] || 'sAMAccountName'
    }
  end

  # 邮件配置
  scope :stmp do
    field :mailer_default_from, default: ENV['ACTION_MAILER_DEFAULT_FROM'], type: :string, display: true
    field :mailer_default_to, default: ENV['ACTION_MAILER_DEFAULT_TO'], type: :string, display: true
    field :mailer_options, type: :hash, readonly: true, default: {
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'].to_i,
      domain: ENV['SMTP_DOMAIN'],
      username: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      auth_method: ENV['SMTP_AUTH_METHOD'],
      enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'],
    }
  end

  # 备份
  field :backup, type: :hash, readonly: true, default: {
    path: 'public/backup',
    keep_time: 604800,
    pg_schema: 'public',
  }

  # 版本信息（只读）
  scope :information do
    field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true, display: true
    field :vcs_ref, default: (ENV['ZEALOT_VCS_REF']), type: :string, readonly: true, display: true
    field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true, display: true
    field :build_date, default: ENV['BUILD_DATE'], type: :string, readonly: true, display: true
  end

  def readonly?
    self.class.get_field(var.to_sym).try(:[], :readonly) === true
  end

  def field_validates
    validates = Setting.validators_on(var)
    validates.each_with_object([]) do |validate, obj|
      next unless value = validate_value(validate)

      obj << value
    end
  end

  private

  def validate_value(validate)
    case validate
    when ActiveModel::Validations::PresenceValidator
      '不能为空值'
    when ActiveRecord::Validations::LengthValidator
      minimum = validate.options[:minimum]
      maximum = validate.options[:maximum]
      "长度限制： #{minimum} ~ #{maximum} 位"
    when ActiveModel::Validations::InclusionValidator
      values = validate.send(:delimiter)
      "可选值： #{values.join(', ')}"
    end
  end
end
