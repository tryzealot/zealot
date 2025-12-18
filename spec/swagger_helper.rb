# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_specs = {
    "v1/swagger_#{I18n.default_locale}.json" => {
      openapi: '3.1.0',
      info: {
        title: 'Zealot API',
        version: 'v1.4',
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
          appScopeParam: {
            scope: {
              in: :query,
              name: :scope,
              required: false,
              description: I18n.t('api.parameters.app_scope'),
              schema: {
                type: :string,
                # enum: ['all', 'archived', 'active'], 
              }
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
              id: { type: :integer, format: :int32, example: 1 },
              name: { type: :string, example: 'First App' },
              archived: { type: :boolean, example: false },
              schemes: { type: :array, items: { '$ref': '#/components/schemas/Scheme' }}
            }
          },
          AppVersionsIndex: {
            description: I18n.t('api.schemas.app_versions.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 1 },
              app_name: { type: :string, example: 'First App' },
              bundle_id: { type: :string, example: '*' },
              git_url: { type: :string, example: 'https://github.com/tryzealot/zealot' },
              app: { '$ref': '#/components/schemas/App' },
              scheme: { '$ref': '#/components/schemas/Scheme' },
              releases: { type: :array, items: { '$ref': '#/components/schemas/Release' }}
            }
          },
          App: {
            description: I18n.t('api.schemas.app.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 1 },
              name: { type: :string, example: 'First App' },
              schemes: { type: :array, items: { '$ref': '#/components/schemas/Scheme' }},
              collaborators: { type: :array, items: { '$ref': '#/components/schemas/Collaborator' }},
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
            properties: {
              id: { type: :integer, format: :int32, example: 1 },
              name: { type: :string, example: 'Production' },
              new_build_callout: { type: :boolean, example: true },
              retained_builds: { type: :integer, format: :int32, example: 0 },
              channels: { type: :array, items: { '$ref': '#/components/schemas/Channel' }}
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
              download_filename_type: { type: :string, example: 'original' },
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
              changelog: { type: :array, items: { '$ref': '#/components/schemas/ReleaseChangelog' }},
              text_changelog: { type: :string, example: '- bump 1.1\n-n fixes bugs' },
              custom_fields: { type: :array, items: { '$ref': '#/components/schemas/ReleaseCustomField' }},
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
              icon: { type: :string, example: 'fa-solid fa-flag' },
              name: { type: :string, example: 'Country' },
              value: { type: :string, example: 'China' },
            }
          },

          # DebugFile
          DebugFile: {
            description: I18n.t('api.schemas.debug_file.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 31 },
              app_name: { type: :string, example: 'First App' },
              device_type: { type: :string, enum: %i[ios android], example: 'iOS' },
              release_version: { type: :string, example: '3.2.1' },
              build_version: { type: :string, example: '8621' },
              file_url: { type: :string, example: 'http://tryzealt.ews.im/debug_files/31/download' },
              metadata: { type: :array, items: {
                oneOf: [
                  { '$ref': '#/components/schemas/DebugFileMetadataDSYM' },
                  { '$ref': '#/components/schemas/DebugFileMetadataProguard' }
                ]
              }}
            }
          },

          DebugFileMetadataProguard: {
            description: I18n.t('api.schemas.metadata_proguard.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 100 },
              category: { type: :string, example: 'Proguard' },
              uuid: { type: :string, example: '2364df02-a44e-4859-9ea1-de25c93d54d5' },
              package_name: { type: :string, example: 'im.ews.zealot.android.example' },
              files: { type: :array, items: { '$ref': '#/components/schemas/MetadataProguardFile' }},
              created_at: { type: :date, example: '2024-03-01 12:00:21 +0800' }
            }
          },
          MetadataProguardFile: {
            description: I18n.t('api.schemas.metadata_proguard_file.description'),
            type: :object,
            properties: {
              name: { type: :string, example: 'AndroidManitest.xml' },
              size: { type: :integer, example: 49241 },
            }
          },
          DebugFileMetadataDSYM: {
            description: I18n.t('api.schemas.metadata_dsym.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 200 },
              category: { type: :string, example: 'dSYM' },
              uuid: { type: :string, example: '2364df02-a44e-4859-9ea1-de25c93d54d5' },
              bundle_id: { type: :string, example: 'im.ews.zealot.iphone.example' },
              name: { type: :string, example: 'ExampleApp' },
              extension: { type: :boolean, example: false },
              size: { type: :integer, example: 32048613 },
              created_at: { type: :date, example: '2024-03-01 12:00:21 +0800' }
            }
          },

          # User
          User: {
            description: I18n.t('api.schemas.user.description'),
            type: :object,
            properties: {
              id: { type: :integer, format: :int32, example: 101 },
              username: { type: :string, example: 'foo' },
              email: { type: :string, example: 'foo@example.com' },
              locale: { type: :string, enum: User.locales.keys, example: User.locales.keys[0] },
              appearance: { type: :string, enum: User.appearances.keys, example: User.appearances.keys[0] },
              timezone: { type: :string, enum: User.timezones.keys, example: User.timezones.keys[0] },
              role: { type: :string, enum: User.roles.keys, example: User.roles.keys[0] },
            }
          },

          # Version information
          Version: {
            description: I18n.t('api.schemas.version.description'),
            type: :object,
            properties: {
              version: { type: :integer, format: :int32, example: '6.0.0' },
              vcs_ref: { type: :string, example: 'effe99c25b79fd55d3e1959ea3af0bcb6b75ba1d' },
              build_date: { type: :string, example: '2024-05-23T06:04:48.989Z' }
            }
          },

          # Health check
          Health: {
            description: I18n.t('api.schemas.health.description'),
            type: :object,
            properties: {
              healthy: { type: :boolean, example: true },
              message: { type: :string, example: 'healthy' }
            }
          },

          Unhealth: {
            description: I18n.t('api.schemas.health.description'),
            type: :object,
            properties: {
              healthy: { type: :boolean, example: false },
              message: { type: :string, example: 'unhealthy' }
            }
          }
        },

        responses: {
          Unauthorized: {
            description: I18n.t('api.responses.unauthorized.description'),
            type: :object,
            required: %w[error],
            properties: {
              error: { type: :string, example: 'Unauthorized user token' },
            }
          },
          NotFound: {
            description: I18n.t('api.responses.not_found.default'),
            type: :object,
            required: %w[error],
            properties: {
              error: { type: :string, example: 'Record not found' },
            }
          },
          Destroyed: {
            description: I18n.t('api.responses.destroyed.default'),
            type: :object,
            required: %w[message],
            properties: {
              message: { type: :string, example: 'OK' },
            }
          },
        },
      },
      definitions: {
        ListAppOptions: {

        },
        UploadAppOptions: {
          description: I18n.t('api.definitions.upload_options.description'),
          type: :object,
          required: %i[ channel_key file ],
          properties: {
            channel_key: { type: :string, description: I18n.t('api.definitions.upload_options.properties.channel_key') },
            file: { type: :file, description: I18n.t('api.definitions.upload_options.properties.file') },
            name: { type: :string, description: I18n.t('api.definitions.upload_options.properties.name') },
            password: { type: :string, description: I18n.t('api.definitions.upload_options.properties.password') },
            release_type: { type: :string, description: I18n.t('api.definitions.upload_options.properties.release_type') },
            source: { type: :string, description: I18n.t('api.definitions.upload_options.properties.source') },
            changelog: { type: :array, items: { '$ref': '#/components/schemas/ReleaseChangelog' }, description: I18n.t('api.definitions.upload_options.properties.changelog')},
            branch: { type: :string, description: I18n.t('api.definitions.upload_options.properties.branch') },
            git_commit: { type: :string, description: I18n.t('api.definitions.upload_options.properties.git_commit') },
            ci_url: { type: :string, description: I18n.t('api.definitions.upload_options.properties.ci_url') },
            custom_fields: { type: :array, items: { '$ref': '#/components/schemas/ReleaseCustomField' }, description: I18n.t('api.definitions.upload_options.properties.custom_fields')},
          }
        },
        AppOptions: {
          description: I18n.t('api.definitions.app_options.description'),
          type: :object,
          required: %i[ name ],
          properties: {
            name: { type: :string, description: I18n.t('api.definitions.app_options.properties.name') }
          }
        },
        SchemeOptions: {
          description: I18n.t('api.definitions.scheme_options.description'),
          type: :object,
          required: %i[ name ],
          properties: {
            name: { type: :string, description: I18n.t('api.definitions.scheme_options.properties.name') },
            new_build_callout: { type: :boolean, default: true, description: I18n.t('api.definitions.scheme_options.properties.new_build_callout') },
            retained_builds: { type: :integer, format: :int32, default: 0, description: I18n.t('api.definitions.scheme_options.properties.retained_builds') }
          }
        },
        ChannelOptions: {
          description: I18n.t('api.definitions.channel_options.description'),
          type: :object,
          required: %i[ name device_type ],
          properties: {
            name: { type: :string, description: I18n.t('api.definitions.channel_options.properties.name') },
            device_type: { type: :string, enum: Channel.device_types.keys, description: I18n.t('api.definitions.channel_options.properties.device_type') },
            slug: { type: :string, description: I18n.t('api.definitions.channel_options.properties.slug') },
            bundle_id: { type: :string, description: I18n.t('api.definitions.channel_options.properties.bundle_id') },
            git_url: { type: :string, description: I18n.t('api.definitions.channel_options.properties.git_url') },
            password: { type: :string, description: I18n.t('api.definitions.channel_options.properties.password') },
            download_filename_type: { type: :string, enum: Channel.download_filename_types.keys, description: I18n.t('api.definitions.channel_options.properties.download_filename_type') }
          }
        },
        ReleaseOptions: {
          description: I18n.t('api.definitions.release_options.description'),
          type: :object,
          properties: {
            build_version: { type: :string, description: I18n.t('api.definitions.release_options.properties.build_version') },
            release_version: { type: :string, description: I18n.t('api.definitions.release_options.properties.release_version') },
            release_type: { type: :string, description: I18n.t('api.definitions.release_options.properties.release_type') },
            source: { type: :string, description: I18n.t('api.definitions.release_options.properties.source') },
            changelog: { type: :array, items: { '$ref': '#/components/schemas/ReleaseChangelog' }, description: I18n.t('api.definitions.release_options.properties.changelog')},
            branch: { type: :string, description: I18n.t('api.definitions.release_options.properties.branch') },
            git_commit: { type: :string, description: I18n.t('api.definitions.release_options.properties.git_commit') },
            ci_url: { type: :string, description: I18n.t('api.definitions.release_options.properties.ci_url') },
            custom_fields: { type: :array, items: { '$ref': '#/components/schemas/ReleaseCustomField' }, description: I18n.t('api.definitions.release_options.properties.custom_fields')},
          }
        },
        CollaboratorOptions: {
          description: I18n.t('api.definitions.collaborator_options.description'),
          type: :object,
          required: %i[ role ],
          properties: {
            role: { type: :string, enum: Collaborator.roles.keys, description: I18n.t('api.definitions.collaborator_options.properties.role') }
          }
        },
        UserOptions: {
          description: I18n.t('api.definitions.user_options.description'),
          type: :object,
          required: %i[ username email password ],
          properties: {
            username: { type: :string, description: I18n.t('api.definitions.user_options.properties.username') },
            email: { type: :string, description: I18n.t('api.definitions.user_options.properties.email') },
            password: { type: :string, description: I18n.t('api.definitions.user_options.properties.password') },
            locale: { type: :string, enum: User.locales.keys, description: I18n.t('api.definitions.user_options.properties.locale') },
            appearance: { type: :string, enum: User.appearances.keys, description: I18n.t('api.definitions.user_options.properties.appearance') },
            timezone: { type: :string, enum: User.timezones.keys, description: I18n.t('api.definitions.user_options.properties.timezone') },
            role: { type: :string, default: :user, enum: User.roles.keys, description: I18n.t('api.definitions.user_options.properties.role') },
          }
        },
        DebugFileOptions: {
          description: I18n.t('api.definitions.debug_file_options.description'),
          type: :object,
          required: %i[ channel_key file ],
          properties: {
            channel_key: { type: :string, description: I18n.t('api.definitions.debug_file_options.properties.channel_key') },
            file: { type: :file, description: I18n.t('api.definitions.debug_file_options.properties.file') },
            release_version: { type: :string, description: I18n.t('api.definitions.debug_file_options.properties.release_version') },
            build_version: { type: :string, description: I18n.t('api.definitions.debug_file_options.properties.build_version') },
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
