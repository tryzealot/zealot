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
          'token': []
        }
      ],
      components: {
        securitySchemes: {
          token: {
            type: :apiKey,
            name: :token,
            in: :query,
            description: I18n.t('api.security.token.description')
          },
        },

        parameters: {
          channelKeyParam: {
            in: :query,
            name: :channel_key,
            required: true,
            description: I18n.t('api.parameters.channel_key'),
            schema: {
              type: :string
            }
          },
          buildVersionParam: {
            in: :query,
            name: :build_version,
            required: true,
            description: I18n.t('api.parameters.build_version'),
            schema: {
              type: :string
            }
          },
          releaseVersionParam: {
            in: :query,
            name: :release_version,
            required: true,
            description: I18n.t('api.parameters.release_version'),
            schema: {
              type: :string
            }
          },
          collaboratorRoleParam: {
            in: :query,
            name: :role,
            required: true,
            description: I18n.t('api.parameters.collaborator_role'),
            schema: {
              type: :string,
              enum: Collaborator.roles.keys
            }
          },
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
          # App
          AppIndex: {
            description: I18n.t('api.schemas.app_index.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              name: { type: :string },
              schemes: { type: :array, '$ref': '#/components/schemas/Scheme' }
            }
          },
          AppVersionsIndex: {
            description: I18n.t('api.schemas.app_versions_index.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 1 },
              app_name: { type: :string, example: 'First App' },
              bundle_id: { type: :string, example: '*' },
              git_url: { type: :string, example: 'https://github.com/tryzealot/zealot' },
              app: { '$ref': '#/components/schemas/App' },
              scheme: { '$ref': '#/components/schemas/Scheme' },
              releases: { type: :array, '$ref': '#/components/schemas/Release' }
            }
          },
          App: {
            description: I18n.t('api.schemas.app.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 1 },
              name: { type: :string, example: 'First App' },
              schemes: { type: :array, '$ref': '#/components/schemas/Scheme' },
              collaborators: { type: :array, '$ref': '#/components/schemas/Collaborator' },
            }
          },
          Collaborator: {
            description: I18n.t('api.schemas.collaborator.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 2 },
              username: { type: :string, example: 'foo' },
              email: { type: :string, example: 'foo@example.com' },
              role: { type: :string, example: 'developer' },
            }
          },
          Scheme: {
            description: I18n.t('api.schemas.scheme.description'),
            type: :object,
            examples: { '$ref': '#/components/examples/Scheme' },
            properties: {
              id: { type: :integer, format: :int32, example: 1 },
              name: { type: :string, example: 'Production' },
              new_build_callout: { type: :boolean, example: true },
              retained_builds: { type: :integer, format: :int32, example: 0 },
              channels: { type: :array, '$ref': '#/components/schemas/Channel' }
            }
          },
          Channel: {
            description: I18n.t('api.schemas.channel.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 4 },
              name: { type: :string, example: 'App Store' },
              slug: { type: :string, example: 'Sk3y' },
              device_type: { type: :string, example: 'Android' },
              bundle_id: { type: :string, example: '*' },
              git_url: { type: :string, example: 'https://github.com/tryzealot/zealot' },
              has_password: { type: :boolean, example: false },
            }
          },
          Release: {
            description: I18n.t('api.schemas.release.description'),
            type: :object,
            properties: {
              version: { type: :integer, format: :int32, example: 100 },
              app_name: { type: :string, example: 'Zealot' },
              bundle_id: { type: :string, example: 'im.ews.zealot' },
              source: { type: :string, example: 'API' },
              branch: { type: :string, example: 'develop' },
              git_commit: { type: :string, example: 'bc58e308dd1caf2226a402291839afbbdabcabf0' },
              ci_url: { type: :string, example: 'https://github.com/tryzealot/zealot/actions/runs/9211335126' },
              size: { type: :integer, example: 392173 },
              platform: { type: :string, example: 'iOS' },
              device_type: { type: :string, example: 'iPhone' },
              icon_url: { type: :string, example: 'https://tryzealot.ews.im/assets/zealot-icon-123e8c86.png' },
              install_url: { type: :string, example: 'https://tryzealot.ews.im/M9DJa/681/download' },
              changelog: { type: :array, '$ref': '#/components/schemas/ReleaseChangelog' },
              text_changelog: { type: :string, example: '- bump 1.1\n-n fixes bugs' },
              custom_fields: { type: :array, '$ref': '#/components/schemas/ReleaseCustomField' },
              created_at: { type: :date, example: '2024-03-01 12:00:00 +0800' },
            }
          },
          ReleaseChangelog: {
            description: I18n.t('api.schemas.release_changelog.description'),
            type: :object,
            properties: {
              date: { type: :string, example: '2024-03-01 12:00:00 +0800' },
              author: { type: :string, example: 'foo' },
              email: { type: :string, example: 'foo@example.com' },
              message: { type: :string, example: 'fixes bugs' },
            }
          },
          ReleaseCustomField: {
            description: I18n.t('api.schemas.release_custom_field.description'),
            type: :object,
            properties: {
              icon: { type: :string, example: 'fas fa-flag' },
              name: { type: :string, example: 'Country' },
              value: { type: :string, example: 'China' },
            }
          },

          # DebugFile
          DebugFile: {
            description: I18n.t('api.schemas.debug_file.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              app_name: { type: :string },
              device_type: { type: :string },
              release_version: { type: :string },
              build_version: { type: :string },
              file_url: { type: :string },
              metadata: { type: :array, items: {
                oneOf: [
                  { '$ref': '#/components/schemas/DebugFileMetadataDSYM' },
                  { '$ref': '#/components/schemas/DebugFileMetadataProguard' }
                ]
              }}
            }
          },

          DebugFileMetadataDSYM: {
            description: I18n.t('api.schemas.debug_file_metadata.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              category: { type: :string },
              uuid: { type: :string },
              package_name: { type: :string },
              files: { type: :object, proterties: {
                name: { type: :string },
                size: { type: :integer },
              }},
              created_at: { type: :date }
            }
          },
          DebugFileMetadataProguard: {
            description: I18n.t('api.schemas.debug_file_metadata.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32 },
              category: { type: :string },
              uuid: { type: :string },
              bundle_id: { type: :string },
              name: { type: :string },
              extension: { type: :boolean },
              size: { type: :integer },
              created_at: { type: :date }
            }
          },
        },

        responses: {
          Unauthorized: {
            description: I18n.t('api.responses.unauthorized.description'),
            type: :object,
            required: %w[error],
            properties: {
              error: { type: :string },
            }
          },
          NotFound: {
            description: I18n.t('api.responses.not_found.default'),
            type: :object,
            required: %w[error],
            properties: {
              error: { type: :string },
            }
          }
        },

        examples: {
          Scheme: {
            summary: I18n.t('api.examples.scheme.summary'),
            value: {
              id: 1,
              name: 'Production',
              new_build_callout: true,
              retained_builds: 0,
              channels: { '$ref': '#/components/examples/Channel' }
            }
          },
          Channel: {
            summary: I18n.t('api.examples.channel.summary'),
            value: {
              id: 1,
              name: 'Production',
              new_build_callout: true,
              retained_builds: 0
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
            changelog: { '$ref': '#/components/schemas/ReleaseChangelog' },
            branch: { type: :string },
            git_commit: { type: :string },
            ci_url: { type: :string },
            custom_fields: { type: :array, '$ref': '#/components/schemas/ReleaseCustomField' },
          }
        }
      }
    }
  }

  config.openapi_format = :json

  config.after do |example|
    next if example.metadata[:swagger].nil?
    next if response.nil? || response.body.blank? || example.metadata[:response][:schema].nil?

    example.metadata[:response][:content] = {
      'application/json' => {
        examples: {
          'Example': {
            value: JSON.parse(response.body, symbolize_names: true)
          },
        },
        schema: {
          '$ref': example.metadata[:response][:schema]['$ref']
        }
      }
    }
  end
end
