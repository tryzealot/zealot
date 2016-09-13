module DevisePermittedParameters
  extend ActiveSupport::Concern

  included do
    before_filter :configure_permitted_parameters
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) << :name
    devise_parameter_sanitizer.permit(:account_update) << :name
  end

end

DeviseController.send :include, DevisePermittedParameters
