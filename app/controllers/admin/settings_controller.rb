class Admin::SettingsController < ApplicationController
  # before_action :get_setting, only: [:edit, :update]

  def index
    @title = '系统配置'
    @settings = Setting.site_configs
  end

  private

    def setting_params
      params.require(:setting).permit(:host, :user_limits, :admin_emails,
        :captcha_enable, :notification_options)
    end
end
