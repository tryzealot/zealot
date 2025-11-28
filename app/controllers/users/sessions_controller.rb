# frozen_string_literal: true

class Users::SessionsController < Devise::Passwordless::SessionsController
  def create
    if magic_link_request?
      super
    else
      Devise::SessionsController.instance_method(:create).bind(self).call
    end
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
end
