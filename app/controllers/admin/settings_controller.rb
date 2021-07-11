# frozen_string_literal: true

class Admin::SettingsController < ApplicationController
  before_action :set_setting, only: %i[edit update]

  def index
    @title = '系统配置'
    @settings = Setting.site_configs
  end

  def edit
    @title = '编辑设置'
  end

  def update
    new_value = setting_param[:value]
    new_value = JSON.parse(new_value) if setting_param[:type] == 'hash'
    if @setting.value != new_value
      @setting.value = new_value
      return render :edit unless @setting.save

      redirect_to admin_settings_path, notice: "保存成功."
    else
      redirect_to admin_settings_path
    end
  end

  private

  def set_setting
    @setting = Setting.find_or_default(var: params[:id])
  end

  def setting_param
    params[:setting].permit!
  end
end
