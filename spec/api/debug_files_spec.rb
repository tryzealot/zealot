# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'DebugFiles API' do
  path '/debug_files' do
    get I18n.t('api.debug_files.index.title') do
      security []
      tags I18n.t('api.debug_files.default.tags')
      description I18n.t('api.debug_files.index.description')
      operationId 'listDebugFiles'

      include_examples :channel_key_parameter
      include_examples :pagiation_parameters

      produces 'application/json'
      response 200, I18n.t('api.debug_files.default.responses.index') do
        schema type: :array, items: { '$ref': '#/components/schemas/DebugFile' }
        run_test!
      end

      include_examples :unauthorized_response
    end
  end

  path '/debug_files/download' do
    get I18n.t('api.debug_files.download.title') do
      security []
      tags I18n.t('api.debug_files.default.tags')
      description I18n.t('api.debug_files.download.description')
      operationId 'downloadDebugFiles'

      include_examples :channel_key_parameter
      include_examples :paramter, :release_version, required: true
      include_examples :paramter, :build_version
      include_examples :paramter, :order, enum: %i[version upload_date], default: :version

      response 302, I18n.t('api.debug_files.default.responses.download') do
        header 'Location', schema: { type: :string }, description: I18n.t('api.debug_files.default.responses.download')
        run_test!
      end

      include_examples :not_found_response
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
      include_examples :not_found_response
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
      include_examples :not_found_response
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
      include_examples :not_found_response
    end
  end
end
