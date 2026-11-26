# frozen_string_literal: true

class OrganizationsController < ApplicationController
  def new
    @title = t('organizations.upsell.title')
  end

  def create
    redirect_to root_path, alert: t('organizations.upsell.title')
  end
end
