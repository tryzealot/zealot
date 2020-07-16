# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { 'v1' }

  # 系统配置
  field :site_title, default: 'Zealot', type: :string
  field :site_https, default: ENV['ZEALOT_USE_HTTPS'].present?, type: :boolean, readonly: true
  field :site_domain, default: (ENV['ZEALOT_DOMAIN'] || site_https ? 'localhost' : "localhost:#{ENV['ZEALOT_PORT'] || 3000}"), type: :string, readonly: true

  # 模式
  field :registrations_mode, default: (ENV['ZEALOT_REGISTER_ENABLED'] || 'true'), type: :boolean
  field :guest_mode, default: (ENV['ZEALOT_GUEST_MODE'] || 'false'), type: :boolean

  # 邮件配置
  field :mailer_default_from, default: ENV['ACTION_MAILER_DEFAULT_FROM'], type: :string
  field :mailer_default_to, default: ENV['ACTION_MAILER_DEFAULT_TO'], type: :string
  field :mailer_options, type: :hash, readonly: true, default: {
    address: ENV['SMTP_ADDRESS'],
    port: ENV['SMTP_PORT'].to_i,
    domain: ENV['SMTP_DOMAIN'],
    username: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    auth_method: ENV['SMTP_AUTH_METHOD'],
    enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'],
  }

  # 系统信息（只读）
  field :demo_mode, default: (ENV['ZEALOT_DEMO_MODE'] || 'false'), type: :boolean, readonly: true
  field :keep_uploads, default: (ENV['ZEALOT_KEEP_UPLOADS']), type: :boolean, readonly: true

  field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true
  field :vcs_ref, default: (ENV['ZEALOT_VCS_REF']), type: :string, readonly: true
  field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true
  field :build_date, default: ENV['BUILD_DATE'], type: :string, readonly: true

  field :backup, type: :hash, readonly: true, default: {
    path: 'public/backup',
    keep_time: 604800,
    pg_schema: 'public',
  }

  # field :default_locale, default: "en", type: :string
  # field :confirmable_enable, default: "0", type: :boolean
  # field :admin_emails, default: "admin@rubyonrails.org", type: :array
  # field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string, readonly: true
  # field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string, readonly: true
end
