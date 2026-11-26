# frozen_string_literal: true

module Zealot
  # Fallback user organization behaviour for CE (no DB-backed organizations).
  # Pro engine may add actual associations on `User` (e.g. `has_many :organizations`).
  # This concern only defines methods when they are not already present.
  module UserOrganization
    extend ActiveSupport::Concern

    unless defined?(Zealot::Pro)
      included do
        def organizations
          [::Organization.new]
        end
      end
    end
  end
end
