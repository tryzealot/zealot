# frozen_string_literal: true

# Paramters
shared_examples :primary_key_parameter do |key, **options|
  parameter name: (key || :id), in: options.fetch(:in, :path), type: options.fetch(:type, :path),
            required: options.fetch(:required, true), **options
end

shared_examples :pagiation_parameters do
  parameter '$ref': '#/components/parameters/pageParam'
  parameter '$ref': '#/components/parameters/perPageParam'
end

shared_examples :channel_key_parameter do
  parameter '$ref': '#/components/parameters/channelKeyParam'
end

shared_examples :version_parameters do
  parameter '$ref': '#/components/parameters/releaseVersionParam'
  parameter '$ref': '#/components/parameters/buildVersionParam'
end

shared_examples :request_form_body do |ref, **options|
  consumes 'multipart/form-data'
  parameter name: :body, in: :body, schema: { '$ref': ref }, **options
end

shared_examples :request_json_body do |ref, **options|
  consumes 'application/json'
  parameter name: :body, in: :body, schema: { '$ref': ref }, **options
end

# Responses
shared_examples :unauthorized_response do
  response 401, I18n.t('api.responses.unauthorized.description') do
    schema '$ref':  '#/components/responses/Unauthorized'
    run_test!
  end
end

shared_examples :not_found_response do |resource_name, **options|
  response 404, I18n.t(:description, scope: %i[api responses not_found], default: :default, model: resource_name) do #'api.responses.not_found.description') do
    schema '$ref':  '#/components/responses/NotFound'
    run_test!
  end
end
