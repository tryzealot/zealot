# frozen_string_literal: true

class ModalsController < ApplicationController
  before_action :available_only
  before_action :prepare_modal

  # Accept both HTML and turbo stream requests
  respond_to :turbo_stream

  MODAL_CONFIG = {
    'install-issue' => {
      title_key:   'install_issue.title',
      body_key:    'install_issue.body_html',
      # title_locals: ->(record) { { name: record&.name } }
    },
    'cert-expired-issues' => {
      title_key:   'cert_expired_issues.title',
      body_key:    'cert_expired_issues.body_html'
    },
    'sponsor' => {
      title_key: 'sponsor.title',
      body_key:  'sponsor.body_html',
      hide_ok: true
    },
    # 'destroy-apple-key' => {
    #   title_key:      'destroy_apple_key.title',
    #   body_key:       'destroy_apple_key.body',
    #   body_locals:    ->(record) { { name: "#{record.team&.display_name} (#{record.team&.team_id})" } },
    #   confirm_value:  'buttons.destroy',
    #   confirm_link:   ->(c, id) { c.admin_apple_key_path(id) },
    #   record:         ->(id) { AppleKey.find(id) }
    # }
  }.freeze

  AVAILABLE_TYPES = MODAL_CONFIG.keys.freeze

  # GET /modals/:type
  def show
    # render json: @options
  end

  private

  def prepare_modal
    @record = modal_config[:record]&.call(pkid)

    @title = t_with_scope(modal_config[:title_key], modal_config[:title_locals]&.call(@record))
    @body  = t_with_scope(modal_config[:body_key],  modal_config[:body_locals]&.call(@record))

    @confirm_value = modal_config[:confirm_value] ? t_with_scope(modal_config[:confirm_value]) : nil
    @confirm_link  = modal_config[:confirm_link]&.call(self, pkid)

    @options = {
      pkid: pkid,
      pkey: pkey,
      type: type,
      title: @title,
      body: @body,
      hide_ok: modal_config[:hide_ok] || false,
      confirm_value: @confirm_value,
      confirm_link: @confirm_link
    }
  end

  def t_with_scope(key, locals = nil)
    t(key, scope: :modals, **(locals || {}))
  end

  def available_only
    raise ActionController::RoutingError, 'Not Found' unless modal_config
  end

  def modal_config
    @config ||= MODAL_CONFIG[type]
  end

  def type
    @type ||= params[:type].to_s
  end

  def pkid
    @pkid ||= params[:id]
  end

  def pkey
    @pkey
  end
end
