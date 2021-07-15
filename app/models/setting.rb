# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { 'v1' }

  # 系统配置
  scope :general do
    field :site_title, default: 'Zealot', type: :string, validates: { presence: true, length: { in: 3..16 } }, display: true
    field :site_https, default: (Rails.env.production? || ENV['ZEALOT_USE_HTTPS'].present?), type: :boolean, readonly: true
    field :site_domain, default: (ENV['ZEALOT_DOMAIN'] || (site_https ? 'localhost' : "localhost:#{ENV['ZEALOT_PORT'] || 3000}")), type: :string, readonly: true

    field :admin_email, default: (ENV['ZEALOT_ADMIN_EMAIL'] || 'admin@zealot.com'), type: :string, readonly: true
    field :admin_password, default: (ENV['ZEALOT_ADMIN_PASSWORD'] || 'ze@l0t'), type: :string, readonly: true
  end

  # 模式开关
  scope :switch_mode do
    field :registrations_mode, default: (ENV['ZEALOT_REGISTER_ENABLED'] || 'true'), type: :boolean, display: true
    field :guest_mode, default: (ENV['ZEALOT_GUEST_MODE'] || 'false'), type: :boolean, readonly: true, display: true
    field :demo_mode, default: (ENV['ZEALOT_DEMO_MODE'] || 'false'), type: :boolean, readonly: true, display: true
  end

  # 上传文件保留策略
  scope :limits do
    field :keep_uploads, default: (ENV['ZEALOT_KEEP_UPLOADS'] || 'false'), type: :boolean, readonly: true
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
      port: ENV['LDAP_PORT'],
      method: ENV['LDAP_METHOD'],
      base_dn: ENV['LDAP_BASE_DN'],
      password: ENV['LDAP_PASSWORD'],
      base: ENV['LDAP_BASE'],
      uid: ENV['LDAP_UID'],
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
    }, display: true
  end

  # 备份
  field :backup, type: :hash, readonly: true, display: true, default: {
    path: 'public/backup',
    keep_time: 604800,
    pg_schema: 'public',
  }


  # 系统信息（只读）
  scope :information do
    field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true
    field :vcs_ref, default: (ENV['ZEALOT_VCS_REF']), type: :string, readonly: true
    field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true
    field :build_date, default: ENV['BUILD_DATE'], type: :string, readonly: true
  end

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
  end
end
