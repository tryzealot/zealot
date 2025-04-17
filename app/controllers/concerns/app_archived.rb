# frozen_string_literal: true

module AppArchived
  extend ActiveSupport::Concern

  def raise_if_app_archived!(app)
    return unless app.archived

    raise Zealot::Error::AppArchivedDeny, name: app.name
  end
end