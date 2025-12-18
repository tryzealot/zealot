# frozen_string_literal: true

class DebugFileMetadatum < ApplicationRecord
  belongs_to :debug_file

  self.inheritance_column = :_type_disabled

  def category
    return 'Proguard' if type == 'proguard'

    'dSYM'
  end

  # dSYM
  def bundle_id
    return unless dsym?

    data['identifier']
  end

  def extension # rubocop:disable Naming/PredicatePrefix
    data['main'] != true
  end

  def name
    object
  end

  # Proguard
  def package_name
    object
  end

  def files
    return unless proguard?

    data['files']
  end

  # Helpers
  def proguard?
    type == 'proguard'
  end

  def dsym?
    !proguard?
  end
end
