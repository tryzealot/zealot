# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Health API' do

  path '/health' do
    get I18n.t('api.health.show.title') do
      security []
      tags I18n.t('api.health.default.tags')
      description I18n.t('api.health.show.description')
      operationId 'gethealthintext'

      produces 'text/plain'
      response 200, 'healthly' do
        schema type: :string, example: 'healthy'
        run_test!
      end

      response 500, 'unhealthy' do
        schema type: :string, example: 'unhealthy'
        run_test!
      end
    end
  end

  path '/health.json' do
    get I18n.t('api.health.show.titleJson') do
      security []
      tags I18n.t('api.health.default.tags')
      description I18n.t('api.health.show.description')
      operationId 'gethealthinjson'

      produces 'application/json'
      response 200, 'healthly' do
        schema '$ref': '#/components/schemas/Health'
        run_test!
      end

      response 500, 'unhealthy' do
        schema '$ref': '#/components/schemas/Unhealth'
        run_test!
      end
    end
  end

end
