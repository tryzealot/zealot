# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController

  protected

  def update_resource(resource, params)
    unless params[:current_password].blank? && params[:password].blank? && params[:password_confirmation].blank?
      return super
    end

    params.delete(:current_password)
    resource.update_without_password(params)
    true
  end

  def after_update_path_for(resource)
    sign_in_after_change_password? ? edit_user_registration_path : new_session_path(resource_name)
  end
end
