# frozen_string_literal: true

class Setting < RailsSettings::Base
  include SettingHelper
  include SettingValidate
  include SettingSuger

  before_save     :convert_third_party_enabled_value, if: :third_party_auth_scope?
  before_save     :mark_restart_flag, if: :need_restart?
  before_destroy  :mark_restart_flag, if: :need_restart?

  cache_prefix { 'v2' }

  scope :general do
    field :site_title, default: 'Zealot', type: :string, display: true,
          validates: { presence: true, length: { in: 3..16 } }
    field :site_https, default: site_https, type: :boolean, readonly: true, display: true
    field :site_domain, default: (ENV['ZEALOT_DOMAIN'] || default_domain), type: :string,
          restart_required: true, display: true
    field :site_locale, default: Rails.configuration.i18n.default_locale.to_s, type: :string, display: true,
          validates: { presence: true, inclusion: { in: Rails.configuration.i18n.available_locales.map(&:to_s) } }
    field :site_appearance, default: (ENV['ZEALOT_APPEARANCE'] || builtin_appearances.keys[0].to_s),
          type: :string, display: true,
          validates: { presence: true, inclusion: { in: builtin_appearances.keys.map(&:to_s) } }
    field :admin_email, default: (ENV['ZEALOT_ADMIN_EMAIL'] || 'admin@zealot.com'), type: :string, readonly: true
    field :admin_password, default: (ENV['ZEALOT_ADMIN_PASSWORD'] || 'ze@l0t'), type: :string, readonly: true
  end

  scope :presets do
    field :preset_schemes, default: builtin_schemes, type: :array, display: true,
          validates: { json: { format: :array } }
    field :preset_role, default: 'user', type: :string, display: true,
          validates: { presence: true, inclusion: { in: builtin_roles.keys.map(&:to_s) } }
    field :per_page, default: ENV.fetch('ZEALOT_PER_PAGE', '25').to_i, type: :integer, display: true,
          validates: { presence: true, numericality: { only_integer: true } }
    field :max_per_page, default: ENV.fetch('ZEALOT_MAX_PER_PAGE', '100').to_i, type: :integer, display: true,
          validates: { presence: true, numericality: { only_integer: true } }
    field :preset_install_limited, default: builtin_install_limited, type: :array, display: true,
          validates: { json: { format: :array, value_allow_empty: true } }
  end

  scope :switch_mode do
    field :registrations_mode, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_REGISTER_ENABLED'] || 'true'),
          type: :boolean, display: true
    field :guest_mode, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_GUEST_MODE'] || 'false'),
          type: :boolean, restart_required: true, display: true
    field :keep_uploads, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_KEEP_UPLOADS'] || 'true'),
          type: :boolean, restart_required: true, display: true
    field :openapi_ui, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_OPENAPI_UI_ENABLED'] || 'false'),
          type: :boolean, restart_required: true, display: true
    field :demo_mode, default: ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_DEMO_MODE'] || 'false'),
          type: :boolean, readonly: true, display: true
  end

  scope :third_party_auth do
    field :feishu, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['FEISHU_ENABLED'] || false),
      app_id: ENV['FEISHU_APP_ID'],
      app_secret: ENV['FEISHU_APP_SECRET'],
    }, validates: { json: { format: :hash } }

    field :gitlab, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['GITLAB_ENABLED'] || false),
      site: ENV['GITLAB_SITE'] || 'https://gitlab.com/api/v4',
      scope: ENV['GITLAB_SCOPE'] || 'read_user',
      app_id: ENV['GITLAB_APP_ID'],
      secret: ENV['GITLAB_SECRET'],
    }, validates: { json: { format: :hash } }

    field :google_oauth, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['GOOGLE_OAUTH_ENABLED'] || false),
      client_id: ENV['GOOGLE_CLIENT_ID'],
      secret: ENV['GOOGLE_SECRET'],
    }, validates: { json: { format: :hash } }

    field :ldap, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['LDAP_ENABLED'] || false),
      host: ENV['LDAP_HOST'],
      port: ENV['LDAP_PORT'] || '389',
      encryption: ENV['LDAP_METHOD'] || ENV['LDAP_ENCRYPTION'] || 'plain', # LDAP_METHOD will be abandon in the future
      bind_dn: ENV['LDAP_BIND_DN'],
      password: ENV['LDAP_PASSWORD'],
      base: ENV['LDAP_BASE'],
      uid: ENV['LDAP_UID'] || 'sAMAccountName'
    }, validates: { json: { format: :hash } }

    field :oidc, type: :hash, display: true, restart_required: true, default: {
      enabled: ActiveModel::Type::Boolean.new.cast(ENV['OIDC_ENABLED'] || false),
      name: ENV['OIDC_NAME'] || 'OIDC Provider',
      client_id: ENV['OIDC_CLIENT_ID'],
      client_secret: ENV['OIDC_CLIENT_SECRET'],
      issuer_url: ENV['OIDC_ISSUER_URL'],
      discovery: ActiveModel::Type::Boolean.new.cast(ENV['OIDC_DISCOVERY'] || false),
      auth_uri: ENV.fetch('OIDC_AUTH_URI', '/authorize'),
      token_uri: ENV.fetch('OIDC_TOKEN_URI', '/token'),
      userinfo_uri: ENV.fetch('OIDC_USERINFO_URI', '/userinfo'),
      scope: ENV.fetch('OIDC_SCOPE', 'openid,email,profile,address'),
      response_type: ENV.fetch('OIDC_RESPONSE_TYPE', 'code'),
      uid_field: ENV.fetch('OIDC_UID_FIELD', 'preferred_username')
    }, validates: { json: { format: :hash } }
  end

  scope :smtp do
    field :mailer_default_from, default: ENV['ACTION_MAILER_DEFAULT_FROM'], type: :string,
      readonly: true, display: true
    field :mailer_default_reply_to, default: ENV['ACTION_MAILER_DEFAULT_TO'], type: :string,
      readonly: true, display: true
    field :mailer_options, type: :hash, display: true, readonly: true,
      default: Rails.configuration.action_mailer.smtp_settings, validates: { json: { format: :hash } }
  end

  scope :information do
    field :version, default: (ENV['ZEALOT_VERSION'] || 'development'), type: :string, readonly: true
    field :vcs_ref, default: (ENV['ZEALOT_VCS_REF'] || ENV['HEROKU_SLUG_COMMIT']), type: :string, readonly: true
    field :build_date, default: (ENV['ZEALOT_BUILD_DATE'] || ENV['HEROKU_RELEASE_CREATED_AT']),
          type: :string, readonly: true
  end

  scope :analytics do
    field :umami_website_id, default: ENV['UMAMI_WEBSITE_ID'], type: :string, display: Setting.demo_mode
    field :clarity_analytics_id, default: ENV['CLARITY_ANALYTICS_ID'], type: :string, display: Setting.demo_mode
    field :google_analytics_id, default: ENV['GOOGLE_ANALYTICS_ID'], type: :string, display: Setting.demo_mode
  end

  # Backup settings
  field :backup, type: :hash, readonly: true, default: {
    path: 'public/backup',
    pg_schema: 'public',
  }, validates: { json: { format: :hash } }
end
