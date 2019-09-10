class WebHooks::PushSerializer < ApplicationSerializer
  # channel model based
  attributes :app_name, :bundle_id, :git_url

  belongs_to :app
  belongs_to :scheme
  has_many   :releases

  def releases
    [object.releases.last]
  end
end