# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Releases API' do
  path '/releases/{id}' do
    put I18n.t('api.releases.update.title') do
      tags I18n.t('api.releases.default.tags')
      description I18n.t('api.releases.update.description')
      operationId 'updateRelease'

      include_examples :primary_key_parameter
      include_examples :request_body, '#/definitions/ReleaseOptions'

      produces 'application/json'
      response 200, I18n.t('api.releases.default.responses.show') do
        schema '$ref': '#/components/schemas/Release'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/releases/{id}' do
    delete I18n.t('api.releases.destroy.title') do
      tags I18n.t('api.releases.default.tags')
      description I18n.t('api.releases.destroy.description')
      operationId 'destroyRelease'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.releases.default.responses.destroy') do
        schema '$ref': '#/components/responses/Destroyed'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end
end
