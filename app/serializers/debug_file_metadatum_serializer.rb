# frozen_string_literal: true

class DebugFileMetadatumSerializer < ApplicationSerializer
  attributes :id, :category, :uuid

  attribute :name, if: -> { object.dsym? }
  attribute :bundle_id, if: -> { object.dsym? }
  attribute :extension, if: -> { object.dsym? }
  attribute :size, if: -> { object.dsym? }

  attribute :package_name, if: -> { object.proguard? }
  attribute :files, if: -> { object.proguard? }

  attribute :created_at
end
