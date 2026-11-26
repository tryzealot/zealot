# frozen_string_literal: true

module Zealot
  module Resolvers
    class OrganizationResolver
      class << self
        def resolve(request: nil, user: nil)
          resolver.call(request: request, user: user)
        end
        alias current resolve

        def resolver
          @resolver ||= default_resolver
        end

        def resolver=(callable)
          @resolver = callable
        end

        def reset!
          @resolver = nil
        end

        private

        def default_resolver
          ->(request: nil, user: nil) { ::Organization.new }
        end
      end
    end
  end
end
