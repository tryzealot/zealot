# frozen_string_literal: true

class Users::SessionsController < Devise::Passwordless::SessionsController
  before_action :set_default_active_tab, only: %i[new create]
  
  def create
    return super if magic_link_request?
    
    # For normal login, use the standard Devise create action
    Devise::SessionsController.instance_method(:create).bind(self).call
  end

  protected

  # Override to permit custom parameters
  def after_magic_link_sent_path_for(resource_or_scope)
    if magic_link_request?
      new_session_path(resource_or_scope)
    else
      after_sign_in_path_for(resource_or_scope)
    end
  end

  def magic_link_request?
    @magic_link_request ||= -> {
      type = params.require(:user).delete(:type)
      type == 'passwordless'
    }.call
  end

  private
  
  def create_params
    if magic_link_request?
      resource_params.permit(:email, :remember_me)
    else
      resource_params.permit(:email, :password, :remember_me)
    end
  end

  def set_default_active_tab
    @active_tab = params[:tab].presence || 'normal'
  end
end
