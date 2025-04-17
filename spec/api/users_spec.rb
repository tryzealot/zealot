# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API' do

  path '/users' do
    get I18n.t('api.users.index.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.index.description')
      operationId 'listUser'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.users.default.responses.index') do
        schema type: :array, items: { '$ref': '#/components/schemas/User' }
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/users/{id}' do
    get I18n.t('api.users.show.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.show.description')
      operationId 'getUser'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.users.default.responses.show') do
        schema '$ref': '#/components/schemas/User'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/users/search' do
    get I18n.t('api.users.search.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.search.description')
      operationId 'searchUser'

      include_examples :lazy_parameter, :email, in: :query, type: :path, required: true

      produces 'application/json'
      response 200, I18n.t('api.users.default.responses.search') do
        schema type: :array, items: { '$ref': '#/components/schemas/User' }
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/users' do
    post I18n.t('api.users.create.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.create.description')
      operationId 'createUser'

      include_examples :request_body, '#/definitions/UserOptions'

      produces 'application/json'
      response 201, I18n.t('api.users.default.responses.create') do
        schema '$ref': '#/components/schemas/User'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/users/{id}' do
    put I18n.t('api.users.update.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.update.description')
      operationId 'updateUser'

      include_examples :primary_key_parameter
      include_examples :request_body, '#/definitions/UserOptions'

      produces 'application/json'
      response 200, I18n.t('api.users.default.responses.update') do
        schema '$ref': '#/components/schemas/User'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/users/{id}/lock' do
    get I18n.t('api.users.lock.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.lock.description')
      operationId 'lockUser'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 202, I18n.t('api.users.default.responses.update') do
        schema '$ref': '#/components/schemas/User'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/users/{id}/unlock' do
    delete I18n.t('api.users.unlock.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.unlock.description')
      operationId 'unlockUser'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 202, I18n.t('api.users.default.responses.update') do
        schema '$ref': '#/components/schemas/User'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end


  path '/users/{id}' do
    delete I18n.t('api.users.destroy.title') do
      tags I18n.t('api.users.default.tags')
      description I18n.t('api.users.destroy.description')
      operationId 'deleteUser'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.users.default.responses.destroy') do
        schema '$ref': '#/components/responses/Destroyed'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end
end
