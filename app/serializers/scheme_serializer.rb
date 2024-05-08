# frozen_string_literal: true

class SchemeSerializer < ApplicationSerializer
  attributes :id, :name, :new_build_callout, :retained_builds

  has_one :app
  has_many :channels
end
