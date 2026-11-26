# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ExceptionHandler
  include UserRole
  include Customize
  include Breadcrumbable
  include Organizable

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Define custom flash types
  add_flash_types :warn

  skip_before_action :verify_authenticity_token

  around_action :switch_locale
  around_action :switch_timezone, if: :current_user

  before_action :set_sentry_context
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_tenant_user!

  helper_method :current_user, :user_signed_in?, :guest_user, :guest_mode?

  def current_user
    super || (guest_mode? ? guest_user : nil)
  end

  def user_signed_in?
    super && !current_user&.guest?
  end

  def guest_user
    @guest_user ||= GuestUser.new
  end

  def guest_mode?
    Setting.guest_mode
  end

  def raise_not_found
    raise ActionController::RoutingError, t('errors.messages.not_match_url', url: params[:unmatched_route])
  end

  private

  def set_sentry_context
    return unless user_signed_in?

    Sentry.set_user(
      id: current_user.id,
      username: current_user.username,
      email: current_user.email
    )
  end

  DEVISE_PERMITTED_PARAMTERS = %i[
    username email password password_confirmation remember_me 
    locale appearance timezone light_theme dark_theme
  ]
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: DEVISE_PERMITTED_PARAMTERS
    devise_parameter_sanitizer.permit :account_update, keys: DEVISE_PERMITTED_PARAMTERS
    devise_parameter_sanitizer.permit :sign_in, keys: %i[ username email password ]
  end

  def authenticate_tenant_user!
    return if devise_controller?
    return if user_signed_in?
    return if guest_mode?

    authenticate_user!
  end
end
