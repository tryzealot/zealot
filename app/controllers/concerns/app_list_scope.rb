# frozen_string_literal: true

# Shared resolution for the app list: which apps a visitor may see, which scope
# they are browsing, and how that state travels through actions and redirects.
module AppListScope
  extend ActiveSupport::Concern

  private

  def app_list_base_scope
    manage_user_or_guest_mode? ? App.all : current_user.apps
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
    counts = base_scope.group(:archived).count
    archived = counts[true].to_i
    active = counts[false].to_i + counts[nil].to_i

    { 'active' => active, 'archived' => archived, 'all' => active + archived }
  end
end
