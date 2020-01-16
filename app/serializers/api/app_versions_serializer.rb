# frozen_string_literal: true

class Api::AppVersionsSerializer < ApplicationSerializer
  # channel model based
  attributes :app_name, :bundle_id, :git_url

  belongs_to :app
  belongs_to :scheme
  has_many   :releases

  def releases
    page = instance_options[:page]
    per_page = instance_options[:per_page]
    object.releases.page(page).per(per_page).order(id: :desc)
  end
end
