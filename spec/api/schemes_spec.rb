# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Schemes API' do
  path '/apps/{app_id}/schemes' do
    get I18n.t('api.schemes.show.title') do
      tags I18n.t('api.schemes.default.tags')
      description I18n.t('api.schemes.show.description')
      operationId 'getScheme'

      include_examples :primary_key_parameter, :app_id

      produces 'application/json'
      response 200, I18n.t('api.schemes.default.responses.show') do
        schema type: :array, items: { '$ref': '#/components/schemas/Scheme' }
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/apps/{app_id}/schemes' do
    post I18n.t('api.schemes.create.title') do
      tags I18n.t('api.schemes.default.tags')
      description I18n.t('api.schemes.create.description')
      operationId 'createScheme'

      include_examples :primary_key_parameter, :app_id
      include_examples :request_form_body, '#/definitions/SchemeOptions'

      produces 'application/json'
      response 201, I18n.t('api.schemes.default.responses.create') do
        schema '$ref': '#/components/schemas/Scheme'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/schemes/{id}' do
    put I18n.t('api.schemes.update.title') do
      tags I18n.t('api.schemes.default.tags')
      description I18n.t('api.schemes.update.description')
      operationId 'updateScheme'

      include_examples :primary_key_parameter
      include_examples :request_form_body, '#/definitions/SchemeOptions'

      produces 'application/json'
      response 200, I18n.t('api.schemes.default.responses.update') do
        schema '$ref': '#/components/schemas/Scheme'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/schemes/{id}' do
    delete I18n.t('api.schemes.destroy.title') do
      tags I18n.t('api.schemes.default.tags')
      description I18n.t('api.schemes.destroy.description')
      operationId 'deleteScheme'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.schemes.default.responses.destroy') do
        schema '$ref': '#/components/responses/Destroyed'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end
end
