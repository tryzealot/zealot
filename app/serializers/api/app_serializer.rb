# frozen_string_literal: true

class Api::AppSerializer < ApplicationSerializer
  attributes :id, :name, :archived

  has_many :schemes
  has_many :collaborators
end
