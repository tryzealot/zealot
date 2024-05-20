# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ExceptionHandler
  include UserRole

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token

  before_action :set_locale
  before_action :set_sentry_context
  before_action :configure_permitted_parameters, if: :devise_controller?

  def raise_not_found
    raise ActionController::RoutingError, t('errors.messages.not_match_url', url: params[:unmatched_route])
  end

  private

  def set_locale
    I18n.locale = Setting.site_locale
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

  DEVISE_PERMITTED_PARAMTERS = %i[ username email password password_confirmation remember_me ]
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: DEVISE_PERMITTED_PARAMTERS
    devise_parameter_sanitizer.permit :account_update, keys: DEVISE_PERMITTED_PARAMTERS
    devise_parameter_sanitizer.permit :sign_in, keys: %i[ username email password ]
  end
end
