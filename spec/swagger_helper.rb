# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_specs = {
    "v1/swagger_#{I18n.default_locale}.json" => {
      openapi: '3.1.0',
      info: {
        title: 'Zealot API V1',
        version: 'v1.2',
        contact: {
          url: 'https://github.com/tryzealot/zealot'
        },
        description: I18n.t('api.info.description')
      },
      servers: [
        {
          url: 'https://tryzealot.ews.im/api',
          description: I18n.t('api.servers.description')
        }
      ],
      paths: {},
      security: [
        {
          "token": []
        }
      ],
      components: {
        securitySchemes: {
          token: {
            type: :apiKey,
            name: "token",
            in: :query,
            description: "User token authentication."
          }
        },

        parameters: {
          pageParam: {
            in: :query,
            name: :page,
            required: false,
            description: "Pagination page",
            schema: {
              type: :integer,
              format: :int32,
              minimum: 1,
              default: 1
            }
          },
          perPageParam: {
            in: :query,
            name: :per_page,
            required: false,
            description: "Page size",
            schema: {
              type: :integer,
              format: :int32,
              minimum: 1,
              maximum: 100,
              default: 25
            }
          }
        },

        schemas: {
          AppIndex: {
            description: "App returned in a list",
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              name: { type: :string },
              schemes: { type: :array, "$ref": "#/components/schemas/Scheme" }
            }
          },
          Scheme: {
            description: "Scheme object",
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              name: { type: :string },
              new_build_callout: { type: :boolean },
              retained_builds: { type: :integer, format: :int32 },
              channels: { type: :array, "$ref": "#/components/schemas/Channel" }
            }
          },
          Channel: {
            description: "Channel object",
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              name: { type: :string },
              slug: { type: :string },
              device_type: { type: :string },
              bundle_id: { type: :string },
              git_url: { type: :string },
              has_password: { type: :boolean },
            }
          },
          UnauthorizedResponse: {
            description: "401 Unauthorized Response",
            type: :object,
            properties: {
              error: { type: :string },
            }
          }
        }
      },
      definitions: {
        UploadAppOptions: {
          description: "Upload app form data options",
          type: :object,
          required: [
            :channel_key,
            :file
          ],
          properties: {
            channel_key: { type: :string },
            file: { type: :file },
            name: { type: :string },
            release_type: { type: :string },
            source: { type: :string },
            changelog: { type: :string },
            branch: { type: :string },
            git_commit: { type: :string },
            ci_url: { type: :string },
            custom_fields: { type: :array },
          }
        }
      }
    }
  }

  config.openapi_format = :json
end
