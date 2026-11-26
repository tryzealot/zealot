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

  # Asks the same policy SchemesController#new authorizes against, so a
  # collaborator promoted on the app sees the entry. Checking the global role
  # instead would leave them with the Management section but no way to create.
  # Archived apps are refused separately, because the policy does not know
  # about archived state.
  def can_create_scheme?
    return false if archived?

    SchemePolicy.new(user, app.schemes.build).new?
  end
end
