# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'DebugFiles API' do
  path '/debug_files' do
    get I18n.t('api.debug_files.index.title') do
      tags I18n.t('api.debug_files.default.tags')
      description I18n.t('api.debug_files.index.description')
      operationId 'listDebugFiles'

      include_examples :channel_key_parameter
      include_examples :pagiation_parameters
      include_examples :unauthorized_response

      produces 'application/json'
      response 200, I18n.t('api.debug_files.default.responses.index') do
        schema type: :array, items: { '$ref': '#/components/schemas/DebugFile' }
        run_test!
      end
    end
  end

  path '/debug_files/{id}' do
    get I18n.t('api.debug_files.show.title') do
      tags I18n.t('api.debug_files.default.tags')
      description I18n.t('api.debug_files.show.description')
      operationId 'getDebugFile'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.debug_files.default.responses.show') do
        schema '$ref': '#/components/schemas/DebugFile'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response, I18n.t('api.debug_files.default.tags')
    end
  end

  path '/debug_files' do
    post I18n.t('api.debug_files.upload.title') do
      tags I18n.t('api.debug_files.default.tags')
      description I18n.t('api.debug_files.upload.description')
      operationId 'uploadDebugFile'

      include_examples :request_form_body, '#/definitions/DebugFileOptions'

      produces 'application/json'
      response 200, I18n.t('api.debug_files.default.responses.upload') do
        schema '$ref': '#/components/schemas/DebugFile'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response, I18n.t('api.debug_files.default.tags')
    end
  end

  path '/debug_files/{id}' do
    delete I18n.t('api.debug_files.destroy.title') do
      tags I18n.t('api.debug_files.default.tags')
      description I18n.t('api.debug_files.destroy.description')
      operationId 'destroyDebugFile'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.debug_files.default.responses.destroy') do
        schema '$ref': '#/components/responses/Destroyed'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response, I18n.t('api.debug_files.default.tags')
    end
  end
end
