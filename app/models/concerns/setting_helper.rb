# frozen_string_literal: true

module SettingHelper
  extend ActiveSupport::Concern

  REPO_URL = 'https://github.com/tryzealot/zealot'

  class_methods do
    include AbstractController::Translation

    def builtin_schemes
      [
        I18n.t('settings.preset_schemes.beta', default: 'Beta'),
        I18n.t('settings.preset_schemes.adhoc', default: 'AdHoc'),
        I18n.t('settings.preset_schemes.production', default: 'Production')
      ]
    end

    def builtin_roles
      {
        user: t('settings.preset_role.user', default: 'User'),
        developer: t('settings.preset_role.developer', default: 'Developer'),
        admin: t('settings.preset_role.admin', default: 'Admin')
      }
    end

    def builtin_appearances
      {
        light: t('settings.theme_modes.light', default: 'light'),
        dark: t('settings.theme_modes.dark', default: 'dark'),
        auto: t('settings.theme_modes.auto', default: 'auto')
      }
    end

    def builtin_install_limited
      [ 'MicroMessenger', 'DingTalk' ]
    end

    def site_https
      Rails.env.production? || ENV['ZEALOT_USE_HTTPS'].present?
    end

    def site_configs
      group_configs.each_with_object({}) do |(scope, items), obj|
        obj[scope] = items.each_with_object({}) do |item, inner|
          key = item[:key]
          value = send(key.to_sym)
          inner[key] = {
            value: value,
            readonly: item[:readonly]
          }
        end
      end
    end

    def need_restart?
      Rails.configuration.x.restart_required == true
    end

    def restart_required!
      Rails.configuration.x.restart_required = true
    end

    def clear_restart_flag!
      Rails.configuration.x.restart_required = false
    end

    def find_or_default(var:)
      find_by(var: var) || new(var: var)
    end

    def group_configs
      defined_fields.select { |v| v[:options][:display] == true }.group_by { |v| v[:scope] || :misc }
    end

    def host
      "#{protocol}#{site_domain}"
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

    def repo_url
      REPO_URL
    end

    def default_domain
      site_https ? 'localhost' : "localhost:#{ENV['ZEALOT_PORT'] || 3000}"
    end
  end
end
