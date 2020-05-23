# frozen_string_literal: true

class Api::DevicesController < Api::BaseController
  before_action :validate_user_token
  before_action :set_device

  # POST /api/devices/:id?name=MyiPhone
  def update
    raise ActiveRecord::RecordNotFound, "设备 UDID (#{params[:id]}) 不存在" unless @device
    raise ActionController::ParameterMissing, 'name' if device_params[:name].blank?

    @device.update(device_params)
    render json: @device
  end

  protected

  def set_device
    @device = Device.find_by(udid: params[:id])
  end

  def device_params
    params.permit(:name)
  end
end
