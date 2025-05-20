# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Apps API' do
  path '/apps' do
    get I18n.t('api.apps.index.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.index.description')
      operationId 'listApps'
      
      include_examples :lazy_parameter, :scope, enum: %i[all active archived], default: 'all'
      include_examples :pagiation_parameters

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.index') do
        schema type: :array, items: { '$ref': '#/components/schemas/AppIndex' }
        run_test!
      end

      include_examples :unauthorized_response
    end
  end

  path '/apps/version_exist' do
    get I18n.t('api.apps.version_exist.title') do
      security []
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.version_exist.description')
      operationId 'versionExistApps'

      include_examples :lazy_parameter, :channel_key, required: true
      include_examples :lazy_parameter, :bundle_id, required: true
      include_examples :lazy_parameter, :git_commit
      include_examples :lazy_parameter, :release_version
      include_examples :lazy_parameter, :build_version

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.show') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :not_found_response
    end
  end

  path '/apps/versions' do
    get I18n.t('api.apps.versions.title') do
      security []
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.versions.description')
      operationId 'listAppVersions'

      include_examples :channel_key_parameter
      include_examples :pagiation_parameters

      produces 'application/json'
      response '200', I18n.t('api.apps.default.responses.versions') do
        schema '$ref': '#/components/schemas/AppVersionsIndex'
        run_test!
      end

      include_examples :not_found_response
    end
  end

  path '/apps/latest' do
    get I18n.t('api.apps.latest.title') do
      security []
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.latest.description')
      operationId 'getLatestApp'

      include_examples :channel_key_parameter
      include_examples :lazy_parameter, :bundle_id
      include_examples :lazy_parameter, :release_version
      include_examples :lazy_parameter, :build_version

      produces 'application/json'
      response '200', I18n.t('api.apps.default.responses.latest') do
        schema '$ref': '#/components/schemas/AppVersionsIndex'
        run_test!
      end

      include_examples :not_found_response
    end
  end

  path '/apps/upload' do
    post I18n.t('api.apps.upload.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.upload.description')
      operationId 'uploadApp'

      include_examples :request_form_body, '#/definitions/UploadAppOptions'

      produces 'application/json'
      response '201', I18n.t('api.apps.default.responses.upload') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/apps/{id}' do
    get I18n.t('api.apps.show.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.show.description')
      operationId 'getApp'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.show') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/apps' do
    post I18n.t('api.apps.create.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.create.description')
      operationId 'createApp'

      include_examples :request_body, '#/definitions/AppOptions'

      produces 'application/json'
      response 201, I18n.t('api.apps.default.responses.show') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :unauthorized_response
    end
  end

  path '/apps/{id}' do
    put I18n.t('api.apps.update.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.update.description')
      operationId 'updateApp'

      include_examples :primary_key_parameter
      include_examples :request_body, '#/definitions/AppOptions'

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.show') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/apps/{id}' do
    delete I18n.t('api.apps.destroy.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.destroy.description')
      operationId 'destroyApp'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.destroy') do
        schema '$ref': '#/components/responses/Destroyed'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end
end
