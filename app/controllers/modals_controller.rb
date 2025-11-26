# frozen_string_literal: true

class ModalsController < ApplicationController
  before_action :available_only
  before_action :set_body

  # GET /modals/:type
  def show
  end

  private

  def set_body
    case type
    when 'install-issue'
      @title = t('modals.install_issue.title')
      @body = t('modals.install_issue.body_html')
    when 'cert-expired-issues'
      @title = t('modals.cert_expired_issues.title')
      @body = t('modals.cert_expired_issues.body_html')
    end
  end

  AVAILABLE_TYPES = %w[install-issue cert-expired-issues].freeze

  def available_only
    raise ActionController::RoutingError, 'Not Found' unless AVAILABLE_TYPES.include?(type)
  end

  def type
    @type ||= params[:type]
  end
end
