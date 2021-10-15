# frozen_string_literal: true

class Admin::SettingsController < ApplicationController
  before_action :set_setting, only: %i[edit update]
  before_action :verify_editable_setting, only: %i[edit]

  def index
    @title = t('.title')
    @settings = Setting.site_configs
  end

  def edit
    @title = t('.title')
    @value = @setting.value || @setting.default_value

    # FIXME: RailsSettings::Base 初始化会缓存造成 i18n 第一时间拿不到
    # 以至于 index, edit 好些地方都需要兼容
    if @setting.var == 'default_schemes' && (@setting.value.blank? || @setting.value.empty?)
      @value = Setting.present_schemes
    end
  end

  def update
    @title = t('.title')
    new_value = setting_param[:value]
    new_value = JSON.parse(new_value) if setting_param[:type] == 'hash' || setting_param[:type] == 'array'
    if @setting.value != new_value
      @setting.value = new_value
      return render :edit unless @setting.save

      message = t('activerecord.success.update', key: t("admin.settings.#{@setting.var}"))
      redirect_to admin_settings_path, notice: message
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

  def verify_editable_setting
    raise Pundit::NotAuthorizedError, t('admin.settings.no_editable_key') if @setting.readonly? === true
  end
end
