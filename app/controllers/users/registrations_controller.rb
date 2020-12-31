# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def update
    if helpers.default_admin_in_demo_mode?(resource)
      return redirect_to edit_user_registration_url, alert: '演示模式不能编辑默认管理员'
    end

    super
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end
