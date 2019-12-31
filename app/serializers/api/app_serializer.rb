class Api::AppSerializer < ApplicationSerializer
  attributes :id, :name

  has_many :schemes
end