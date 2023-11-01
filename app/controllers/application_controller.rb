# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ExceptionHandler
  include Pundit::Authorization

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token

  around_action :set_locale
  before_action :set_sentry_context

  def raise_not_found
    raise ActionController::RoutingError, t('errors.messages.not_match_url', url: params[:unmatched_route])
  end

  private

  def set_locale(&action)
    I18n.with_locale(Setting.site_locale, &action)
  end

  def set_sentry_context
    Sentry.configure_scope do |scope|
      context = params.to_unsafe_h || {}
      context[:url] = request.url
      scope.set_context('params', context)
    end

    if current_user = session[:current_user_id]
      Sentry.set_user(id: current_user)
    end
  end
end
