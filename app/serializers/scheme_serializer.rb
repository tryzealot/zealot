# frozen_string_literal: true

class SchemeSerializer < ApplicationSerializer
  attributes :id, :name

  has_many :channels
end
