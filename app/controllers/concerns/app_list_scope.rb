# frozen_string_literal: true

# Shared resolution for the app list: which apps a visitor may see, which scope
# they are browsing, and how that state travels through actions and redirects.
module AppListScope
  extend ActiveSupport::Concern

  private

  def app_list_base_scope
    scope = if current_user&.admin? || guest_mode_active?
              App.all
            elsif pro_multi_org_enabled? && current_org_member?
              App.all
            elsif ce_manage_user?
              App.all
            elsif current_user&.respond_to?(:apps)
              current_user.apps
            else
              App.none
            end

    respond_to?(:org_scope) ? org_scope(scope) : scope
  end

  def guest_mode_active?
    respond_to?(:guest_mode?, true) && guest_mode? && current_user&.guest?
  end

  def ce_manage_user?
    return false if pro_multi_org_enabled?

    respond_to?(:manage_user_or_guest_mode?, true) && manage_user_or_guest_mode?
  end

  def current_org_member?
    return false unless respond_to?(:current_org, true)
    return false unless current_org.respond_to?(:persisted?) && current_org.persisted?
    return false unless current_user.respond_to?(:id) && current_user.persisted?

    if current_org.respond_to?(:organization_memberships)
      current_org.organization_memberships.where(user_id: current_user.id).exists?
    elsif current_org.respond_to?(:users)
      current_org.users.where(id: current_user.id).exists?
    else
      false
    end
  end

  def pro_multi_org_enabled?
    Zealot::Resolvers::RoleResolver.multi_org_enabled?
  end

  def resolved_scope
    App.normalize_scope(params[:scope])
  end

  def resolved_sort
    params[:sort].presence_in(%w[asc desc]) || 'asc'
  end

  def app_list_redirect_params(scope: resolved_scope)
    { scope: scope, search: params[:search].presence, sort: params[:sort].presence }.compact
  end

  # One grouped query for the whole toolbar. Counts describe the collection, so
  # they deliberately ignore the search term.
  def scope_counts_for(base_scope)
    counts = base_scope.unscope(:order).group(:archived).count
    archived = counts[true].to_i
    active = counts[false].to_i + counts[nil].to_i

    { 'active' => active, 'archived' => archived, 'all' => active + archived }
  end
end
