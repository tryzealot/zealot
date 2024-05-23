# frozen_string_literal: true

require 'swagger_helper'

describe 'Apps API' do
  path '/apps' do
    get I18n.t('api.apps.list_apps.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.list_apps.description')
      operationId 'listApps'

      parameter '$ref': '#/components/parameters/pageParam'
      parameter '$ref': '#/components/parameters/perPageParam'

      produces 'application/json'
      response '200', I18n.t('api.apps.list_apps.response.200') do
        let(:token) { nil }
        schema type: :array,
               items: { '$ref': '#/components/schemas/AppIndex' }
        run_test!
      end

      response '401', I18n.t('api.apps.list_apps.response.401') do
        schema '$ref': '#/components/schemas/UnauthorizedResponse'
        run_test!
      end
    end
  end

  path '/apps/{id}' do
    get I18n.t('api.apps.get_app.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.get_app.description')
      operationId 'getApp'

      parameter name: :id, in: :path, type: :integer, required: true

      produces 'application/json'
      response '200', 'An App' do
        schema '$ref': '#/components/schemas/AppIndex'
        run_test!
      end

      response '401', 'invalid authentication' do
        schema '$ref': '#/components/schemas/UnauthorizedResponse'
        run_test!
      end

      response '404', 'not found' do
        let(:id) { 1_234_567_890 }
        schema '$ref': '#/components/schemas/UnauthorizedResponse'
        run_test!
      end
    end
  end

  path '/apps/upload' do
    post I18n.t('api.apps.upload_app.title') do
      tags I18n.t('api.apps.default.tags')
      description I18n.t('api.apps.upload_app.description')
      operationId 'uploadApp'

      consumes 'multipart/form-data'
      parameter name: :body, in: :body, schema: {
        '$ref' => '#/definitions/UploadAppOptions'
      }

      produces 'application/json'
      response '201', 'an release of app uploaded' do
        schema '$ref': '#/components/schemas/AppIndex'
        run_test!
      end

      response '401', 'invalid authentication' do
        schema '$ref': '#/components/schemas/UnauthorizedResponse'
        run_test!
      end

      response '404', 'not found' do
        let(:id) { 1_234_567_890 }
        schema '$ref': '#/components/schemas/UnauthorizedResponse'
        run_test!
      end
    end
  end
end
