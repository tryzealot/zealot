# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Apps API' do
  let(:user) { create(:user) }
  let(:app) { create(:app) }

  describe "GET /apps" do
    path '/apps' do
      get I18n.t('api.apps.list_apps.title') do
        tags I18n.t('api.apps.default.tags')
        description I18n.t('api.apps.list_apps.description')
        operationId 'listApps'

        include_examples :pagiation_parameters
        include_examples :unauthorized_response

        produces 'application/json'
        response 200, I18n.t('api.apps.default.responses.app_index') do
          schema type: :array, items: { '$ref': '#/components/schemas/AppIndex' }
          run_test!
        end
      end
    end
  end

  path '/apps/{id}' do
    get I18n.t('api.apps.get_app.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.get_app.description')
      operationId 'getApp'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.app') do
        schema '$ref': '#/components/schemas/AppIndex'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response, I18n.t('api.apps.default.tags')
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
      response '200', I18n.t('api.apps.default.responses.app_versions') do
        schema '$ref': '#/components/schemas/AppVersionsIndex'
        run_test!
      end

      include_examples :not_found_response, I18n.t('api.apps.default.tags')
    end
  end

  path '/apps/latest' do
    get I18n.t('api.apps.latest.title') do
      security []
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.latest.description')
      operationId 'getLatestApp'

      include_examples :channel_key_parameter
      include_examples :version_parameters

      produces 'application/json'
      response '200', I18n.t('api.apps.default.responses.app_latest') do
        schema '$ref': '#/components/schemas/AppVersionsIndex'
        run_test!
      end

      include_examples :not_found_response, I18n.t('api.apps.default.tags')
    end
  end

  path '/apps/upload' do
    post I18n.t('api.apps.upload_app.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.upload_app.description')
      operationId 'uploadApp'

      consumes 'multipart/form-data'
      parameter name: :body, in: :body, schema: { '$ref':  '#/definitions/UploadAppOptions' }

      produces 'application/json'
      response '201', I18n.t('api.apps.default.responses.build_uploaded') do
        schema '$ref': '#/components/schemas/AppIndex'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response, I18n.t('api.apps.default.tags')
    end
  end

  path '/apps' do
    post I18n.t('api.apps.create_app.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.create_app.description')
      operationId 'createApp'

      parameter name: :name, in: :body, type: String

      produces 'application/json'
      response 201, I18n.t('api.apps.default.responses.app') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :unauthorized_response
    end
  end

  path '/apps/{id}' do
    put I18n.t('api.apps.update_app.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.update_app.description')
      operationId 'createApp'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.app') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response, I18n.t('api.apps.default.tags')
    end
  end

  path '/apps/{id}' do
    delete I18n.t('api.apps.destroy_app.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.destroy_app.description')
      operationId 'createApp'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.apps.default.responses.destroy') do
        schema '$ref': '#/components/schemas/App'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response, I18n.t('api.apps.default.tags')
    end
  end
end
