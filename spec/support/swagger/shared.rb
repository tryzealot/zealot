# frozen_string_literal: true

# Paramters
shared_examples :lazy_parameter do |key, **options|
  options[:name] = key || :id
  options[:in] ||= options[:name] == :id ? :path : :query
  options[:type] ||= :string
  options[:required] ||= false

  tranlate_key = options.delete(:description) || "api.parameters.#{options[:name]}"

  description = []
  description << I18n.t(tranlate_key) if I18n.exists?(tranlate_key)

  if enum = options.delete(:enum)
    values = I18n.t("api.parameters.supported_values", values: enum.map(&:to_s).join(", "))
    description << values
  end
  options[:description] = description.join(' / ') if description.present?

  parameter **options
end

shared_examples :primary_key_parameter do |key, **options|
  key ||= :id
  tranlate_key = options.delete(:description) || "api.parameters.#{key}"
  options[:description] = I18n.t(tranlate_key) if I18n.exists?(tranlate_key)

  parameter name: (key || :id), in: options.fetch(:in, :path), type: options.fetch(:type, :string),
            required: options.fetch(:required, true), **options
end

shared_examples :pagiation_parameters do
  parameter '$ref': '#/components/parameters/pageParam'
  parameter '$ref': '#/components/parameters/perPageParam'
end

shared_examples :channel_key_parameter do
  parameter '$ref': '#/components/parameters/channelKeyParam'
end

# workaround to request both form data and json of body
# ref: https://github.com/rswag/rswag/issues/528#issuecomment-1929012414
shared_examples :request_body do |ref, **options|
  metadata[:operation][:requestBody] = {
    required: true,
    content: {
      'application/json': {
        schema: { '$ref': ref }
      },
      'multipart/form-data': {
        schema: { '$ref': ref }
      }
    }
  }
end

# workaround to request both form data and json of body
# ref: https://github.com/rswag/rswag/issues/528#issuecomment-1929012414
shared_examples :request_body do |ref, **options|
  metadata[:operation][:requestBody] = {
    required: true,
    content: {
      'application/json': {
        schema: { '$ref': ref }
      },
      'multipart/form-data': {
        schema: { '$ref': ref }
      }
    }
  }
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

shared_examples :not_found_response do |model, **options|
  # response 404, I18n.t(:description, scope: %i[api responses not_found], default: :default, model: resource_name) do #'api.responses.not_found.description') do
  response 404, I18n.t(:default, scope: %i[api responses not_found]) do
    schema '$ref':  '#/components/responses/NotFound'
    run_test!
  end
end
