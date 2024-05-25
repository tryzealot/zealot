# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Collaborators API' do
  path '/apps/{app_id}/collaborators/{user_id}' do
    get I18n.t('api.collaborators.show.title') do
      tags I18n.t('api.collaborators.default.tags')
      description I18n.t('api.collaborators.show.description')
      operationId 'getCollaborator'

      include_examples :primary_key_parameter, :app_id
      include_examples :primary_key_parameter, :user_id

      produces 'application/json'
      response 200, I18n.t('api.collaborators.default.responses.show') do
        schema '$ref': '#/components/schemas/Collaborator'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/apps/{app_id}/collaborators/{user_id}' do
    post I18n.t('api.collaborators.create.title') do
      tags I18n.t('api.collaborators.default.tags')
      description I18n.t('api.collaborators.create.description')
      operationId 'createCollaborator'

      include_examples :primary_key_parameter, :app_id
      include_examples :primary_key_parameter, :user_id
      include_examples :request_form_body, '#/definitions/CollaboratorOptions'

      produces 'application/json'
      response 201, I18n.t('api.collaborators.default.responses.create') do
        schema '$ref': '#/components/schemas/Collaborator'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/apps/{app_id}/collaborators/{user_id}' do
    put I18n.t('api.collaborators.update.title') do
      tags I18n.t('api.collaborators.default.tags')
      description I18n.t('api.collaborators.update.description')
      operationId 'updateCollaborator'

      include_examples :primary_key_parameter, :app_id
      include_examples :primary_key_parameter, :user_id
      include_examples :request_form_body, '#/definitions/CollaboratorOptions'

      produces 'application/json'
      response 200, I18n.t('api.collaborators.default.responses.update') do
        schema '$ref': '#/components/schemas/Collaborator'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/apps/{app_id}/collaborators/{user_id}' do
    delete I18n.t('api.collaborators.destroy.title') do
      tags I18n.t('api.collaborators.default.tags')
      description I18n.t('api.collaborators.destroy.description')
      operationId 'deleteCollaborator'

      include_examples :primary_key_parameter, :app_id
      include_examples :primary_key_parameter, :user_id

      produces 'application/json'
      response 200, I18n.t('api.collaborators.default.responses.destroy') do
        schema '$ref': '#/components/responses/Destroyed'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end
end
