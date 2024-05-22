# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def update
    if helpers.default_admin_in_demo_mode?(resource)
      return redirect_to edit_user_registration_url, alert: t('errors.messages.invaild_in_demo_mode')
    end

    super
  end

  protected

  def update_resource(resource, params)
    return super unless params[:current_password].blank? && params[:password].blank? && params[:password_confirmation].blank?

    params.delete(:current_password)
    resource.update_without_password(params)
    true
  end

  def after_update_path_for(resource)
    sign_in_after_change_password? ? edit_user_registration_path : new_session_path(resource_name)
  end
end
