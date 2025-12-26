# frozen_string_literal: true

class AppReleaseActivityComponent < ViewComponent::Base
  def initialize(releases, title:, active_id: nil, icon: nil)
    @releases = releases
    @active_id = active_id
    @title = title
    @icon = icon
  end
end
