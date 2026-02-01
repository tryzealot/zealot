# frozen_string_literal: true

class Admin::AppleTeamsController < ApplicationController
  before_action :set_apple_team, only: %i[ edit update ]

  # GET /apple_teams/1/edit
  def edit
  end

  # PATCH/PUT /apple_teams/1
  def update
    unless @apple_team.update(apple_team_params)
      return render :edit, status: :unprocessable_entity
    end

    @apple_key = @apple_team.key

    flash.now[:notice] = t('activerecord.success.update', key: t('simple_form.labels.apple_team.display_name'))
    respond_to do |format|
      format.html { redirect_to admin_apple_key_path(@apple_key) }
      format.turbo_stream
    end
  end

  private

  def set_apple_team
    @apple_team = AppleTeam.find(params[:id])
  end

  def apple_team_params
    params.require(:apple_team).permit(:display_name)
  end
end
