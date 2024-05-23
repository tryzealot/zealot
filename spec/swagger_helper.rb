# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_specs = {
    "v1/swagger_#{I18n.default_locale}.json" => {
      openapi: '3.1.0',
      info: {
        title: 'Zealot API',
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
            description: I18n.t('api.security.token.description')
          }
        },

        parameters: {
          pageParam: {
            in: :query,
            name: :page,
            required: false,
            description: I18n.t('api.parameters.page'),
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
            description: I18n.t('api.parameters.per_page'),
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
            description: I18n.t('api.schemas.app_index.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              name: { type: :string },
              schemes: { type: :array, "$ref": "#/components/schemas/Scheme" }
            }
          },
          App: {
            description: I18n.t('api.schemas.app.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              name: { type: :string },
              schemes: { type: :array, "$ref": "#/components/schemas/Scheme" },
              collaborators: { type: :array, "$ref": "#/components/schemas/Collaborator" },
            }
          },
          Collaborator: {
            description: I18n.t('api.schemas.collaborator.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              username: { type: :string },
              email: { type: :string },
              role: { type: :string },
            }
          },
          Scheme: {
            description: I18n.t('api.schemas.scheme.description'),
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
            description: I18n.t('api.schemas.channel.description'),
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
            description: I18n.t('api.schemas.unauthorized_response.description'),
            type: :object,
            properties: {
              error: { type: :string },
            }
          }
        }
      },
      definitions: {
        UploadAppOptions: {
          description: I18n.t('api.definitions.upload_app_options.description'),
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
