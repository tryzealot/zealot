# frozen_string_literal: true

module Zealot
  module Resolvers
    class RoleResolver
      ROLE_RANKS = {
        'owner' => 4,
        'admin' => 3,
        'developer' => 2,
        'member' => 1,
        'guest' => 0
      }.freeze

      class << self
        def resolve(user:, record: nil, organization: nil)
          resolver.call(user: user, record: record, organization: organization)
        end

        def rank_of(role)
          ROLE_RANKS[role.to_s] || 0
        end

        def highest_role(roles)
          roles.compact.map(&:to_s).max_by { |r| rank_of(r) }
        end

        def resolver
          @resolver ||= default_resolver
        end

        def resolver=(callable)
          @resolver = callable
        end

        def reset!
          @resolver = nil
        end

        def multi_org_enabled?
          return false unless defined?(Zealot::Pro)

          Zealot::Pro.enabled?(:multi_org)
        rescue StandardError
          false
        end

        def default_org?(org)
          return true if org.nil?
          return true if org.respond_to?(:default?) && org.default?
          return true if org.respond_to?(:slug) && org.slug == 'default'

          false
        end

        private

        def default_resolver
          ->(user:, record: nil, organization: nil) do
            return 'guest' if user.nil? || (user.respond_to?(:guest?) && user.guest?)

            # 1. System Admin always has global administrative authority
            return 'admin' if user.respond_to?(:admin?) && user.admin?

            # Resolve target app if record is App or child of App
            app = resolve_app(record)
            org = organization || Current.organization || (app.respond_to?(:organization) ? app.organization : nil)

            # 2. Resolve Organization and App Collaborator roles
            org_role = resolve_org_role(user, org)
            app_role = resolve_app_role(user, app)

            # 3. Synthesize with Highest Privilege Wins
            effective = highest_role([org_role, app_role])
            return effective if effective.present?

            # 4. Fallback for CE / default organization
            if multi_org_enabled? && org.present? && !default_org?(org)
              # In a non-default Pro organization, non-members without app collaboration have no role
              nil
            else
              # In CE or default organization, fall back to user's global role
              (user.respond_to?(:role) && user.role.to_s) || 'member'
            end
          end
        end

        def resolve_app(record)
          return record if record.is_a?(App)
          return record.app if record.respond_to?(:app)
          return record.scheme.app if record.respond_to?(:scheme) && record.scheme.respond_to?(:app)
          return record.channel.app if record.respond_to?(:channel) && record.channel.respond_to?(:app)

          nil
        end

        def resolve_org_role(user, org)
          # An explicit Current.role takes precedence for the ambient tenant
          role = Current.role
          return role.to_s if role.present?

          return nil unless defined?(Zealot::Pro)
          return nil unless org&.respond_to?(:persisted?) && org.persisted?
          return nil unless user.respond_to?(:persisted?) && user.persisted?

          if org.respond_to?(:organization_memberships)
            membership = org.organization_memberships.find_by(user: user)
            return membership.role.to_s if membership&.respond_to?(:role)
          end

          nil
        end

        def resolve_app_role(user, app)
          return nil unless app&.respond_to?(:persisted?) && app.persisted?
          return nil unless user.respond_to?(:persisted?) && user.persisted?

          collaborator = app.collaborators.find_by(user: user) if app.respond_to?(:collaborators)
          return nil unless collaborator

          return 'owner' if collaborator.respond_to?(:owner?) && collaborator.owner?

          collaborator.role.to_s
        end
      end
    end
  end
end
