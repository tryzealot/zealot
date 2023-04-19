# frozen_string_literal: true

class Admin::SettingsController < ApplicationController
  before_action :set_setting, only: %i[ edit update destroy ]
  before_action :verify_editable_setting, only: %i[ edit destroy ]
  after_action :patch_edited_value, only: %i[ edit ]
  after_action :clear_cache_value, only: %i[ update destroy ]

  def index
    @title = t('.title')
    @settings = Setting.site_configs
  end

  def edit
    authorize @setting

    @title = t('.title')
    @value = @setting.value || @setting.default_value
  end

  def update
    authorize @setting

    @title = t('.title')
    @value = setting_param[:value]
    @value = JSON.parse(@value) if setting_param[:type] == 'hash' || setting_param[:type] == 'array'

    if @setting.value != @value
      @setting.value = @value
      return render :edit, status: :unprocessable_entity unless @setting.save

      message = t('activerecord.success.update', key: t("admin.settings.#{@setting.var}"))
      redirect_to admin_settings_path, notice: message
    else
      message = t('activerecord.errors.same_value', key: t("admin.settings.#{@setting.var}"))
      redirect_to admin_settings_path, alert: message
    end
  rescue JSON::ParserError
    @setting.errors.add(:value, :invaild_json)
    @value = @setting.value || @setting.default_value
    return render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize @setting

    key = @setting.var
    @setting.destroy

    notice = t('activerecord.success.destroy', key: t("admin.settings.#{key}"))
    redirect_to admin_settings_path, status: :see_other, notice: notice
  end

  private

  def set_setting
    @setting = Setting.find_or_default(var: params[:id])
  end

  def setting_param
    params[:setting].permit!
  end

  def patch_edited_value
    # FIXME: RailsSettings::Base 初始化会缓存造成 i18n 第一时间拿不到
    # 以至于 index, edit 好些地方都需要兼容
    if @setting.var == 'preset_schemes' && @setting.value.blank?
      @value = Setting.builtin_schemes
    end

    # 值的多语言支持显示
    if @value.is_a?(String) && @value.present?
      @value = t("settings.#{@value}", default: @value)
    end
  end

  def clear_cache_value
    Rails.cache.delete(@setting.var)
  end

  def verify_editable_setting
    readonly = @setting.readonly? === true
    demo_guest_with_secure_key = @setting.value.is_a?(Hash) && helpers.secure_key?(@setting.value)
    if readonly || demo_guest_with_secure_key
      raise Pundit::NotAuthorizedError.new({ query: :edit, record: @setting})
    end
  end
end
