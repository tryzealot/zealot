class Api::BaseSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
end
