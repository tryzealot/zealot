class SchemeSerializer < ApplicationSerializer
  attributes :id, :name

  has_many :channels
end