# frozen_string_literal: true

class Admin::SettingsController < ApplicationController
  before_action :set_setting, only: %i[ edit update destroy ]
  before_action :verify_editable_setting, only: %i[ edit destroy ]
  after_action :clear_cache_value, only: %i[ update destroy ]

  def index
    @title = t('.title')
    @settings = Setting.site_configs
  end

  def edit
    authorize @setting

    @title = t('.title')
    @value = @setting.value_or_default
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
      flash.now.notice = message
    else
      message = t('activerecord.errors.messages.same_value', key: t("admin.settings.#{@setting.var}"))
      flash.now.alert = message
    end

    respond_to do |format|
      format.html { admin_settings_path }
      format.turbo_stream
    end
  rescue JSON::ParserError
    @setting.errors.add(:value, :invaild_json)
    @value = @setting.value || @setting.default_value
    return render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize @setting
    @setting.destroy

    message = t('activerecord.success.destroy', key: t("admin.settings.#{@setting.var}"))
    flash.now.notice = message
    respond_to do |format|
      format.html { admin_settings_path }
      format.turbo_stream
    end
  end

  private

  def set_setting
    @setting = Setting.find_or_default(var: params[:id])
  end

  def setting_param
    params[:setting].permit!
  end

  def clear_cache_value
    Rails.cache.delete(@setting.var)
    Rails.cache.delete('preset_schemes')
  end

  def verify_editable_setting
    readonly = @setting.readonly? === true
    demo_guest_with_secure_key = @setting.value.is_a?(Hash) && helpers.secure_key?(@setting.value)
    if readonly || demo_guest_with_secure_key
      raise Pundit::NotAuthorizedError.new({ query: :edit, record: @setting})
    end
  end
end
