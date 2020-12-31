# frozen_string_literal: true

class ApplicationSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
end
