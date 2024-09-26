# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Channels API' do
  path '/schemes/{scheme_id}/channels' do
    get I18n.t('api.channels.show.title') do
      tags I18n.t('api.channels.default.tags')
      description I18n.t('api.channels.show.description')
      operationId 'getChannel'

      include_examples :primary_key_parameter, :scheme_id

      produces 'application/json'
      response 200, I18n.t('api.channels.default.responses.show') do
        schema type: :array, items: { '$ref': '#/components/schemas/Channel' }
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/schemes/{scheme_id}/channels' do
    post I18n.t('api.channels.create.title') do
      tags I18n.t('api.channels.default.tags')
      description I18n.t('api.channels.create.description')
      operationId 'createChannel'

      include_examples :primary_key_parameter, :scheme_id
      include_examples :request_body, '#/definitions/ChannelOptions'

      produces 'application/json'
      response 201, I18n.t('api.channels.default.responses.create') do
        schema '$ref': '#/components/schemas/Channel'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/channels/{id}' do
    put I18n.t('api.channels.update.title') do
      tags I18n.t('api.channels.default.tags')
      description I18n.t('api.channels.update.description')
      operationId 'updateChannel'

      include_examples :primary_key_parameter
      include_examples :request_body, '#/definitions/ChannelOptions'

      produces 'application/json'
      response 200, I18n.t('api.channels.default.responses.update') do
        schema '$ref': '#/components/schemas/Channel'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end

  path '/channels/{id}' do
    delete I18n.t('api.channels.destroy.title') do
      tags I18n.t('api.channels.default.tags')
      description I18n.t('api.channels.destroy.description')
      operationId 'deleteChannel'

      include_examples :primary_key_parameter

      produces 'application/json'
      response 200, I18n.t('api.channels.default.responses.destroy') do
        schema '$ref': '#/components/responses/Destroyed'
        run_test!
      end

      include_examples :unauthorized_response
      include_examples :not_found_response
    end
  end
end
