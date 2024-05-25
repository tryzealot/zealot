# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Version API' do

  path '/version' do
    get I18n.t('api.version.show.title') do
      security []
      tags I18n.t('api.version.default.tags')
      description I18n.t('api.version.show.description')
      operationId 'getVersion'

      produces 'application/json'
      response 200, I18n.t('api.version.default.responses.show') do
        schema '$ref': '#/components/schemas/Version'
        run_test!
      end
    end
  end

end
