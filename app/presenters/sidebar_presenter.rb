# frozen_string_literal: true

# Supplies the app context sidebar with preloaded schemes/channels and the
# permission/state flags it needs, so views stay query-free.
class SidebarPresenter
  attr_reader :app, :user

  def initialize(app:, user: nil)
    @app = app
    @user = user
  end

  def archived?
    app.archived?
  end

  def schemes
    @schemes ||= app.schemes.includes(:channels)
  end

  def can_create_scheme?
    !archived? && user&.manage?(app: app)
  end
end
