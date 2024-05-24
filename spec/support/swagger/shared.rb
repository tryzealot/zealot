
# Paramters
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

shared_examples :primary_key_parameter do
  parameter name: :id, in: :path, type: :integer, required: true
end

# Responses
shared_examples :unauthorized_response do
  response 401, I18n.t('api.responses.unauthorized.description') do
    schema '$ref':  '#/components/responses/Unauthorized'
    run_test!
  end
end

shared_examples :not_found_response do |resource_name, **options|
  response 404, I18n.t(:description, scope: [:api, :responses, :not_found], default: :default, model: resource_name) do #'api.responses.not_found.description') do
    schema '$ref':  '#/components/responses/NotFound'
    run_test!
  end
end
