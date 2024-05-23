# frozen_string_literal: true

Rails.configuration.to_prepare do
  Rswag::Api.configure do |c|
    c.openapi_root = Rails.root.to_s + '/swagger'
    c.swagger_filter = lambda do |swagger, env|
      swagger['servers'].prepend({
        url: "#{Setting.host}/api",
        description: 'CURRENT'
      })
    end
  end
end
