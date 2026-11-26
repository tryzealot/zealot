# frozen_string_literal: true

module Organizable
  extend ActiveSupport::Concern

  included do
    helper_method :current_org, :org_scope if respond_to?(:helper_method)
    before_action :set_current_tenant
  end

  def current_org
    Current.organization ||= resolve_organization
  end

  def org_scope(relation)
    return relation unless relation.respond_to?(:where)
    return relation unless current_org.respond_to?(:id) &&
                          current_org.respond_to?(:persisted?) &&
                          current_org.persisted?

    # Determine model class (works for ActiveRecord::Relation and model Class)
    model = if relation.respond_to?(:klass)
      relation.klass
    elsif relation.is_a?(Class)
      relation
    else
      nil
    end

    # Only apply organization scoping when the model actually has organization_id column
    if model && model.respond_to?(:column_names) && model.column_names.include?('organization_id')
      relation.where(organization_id: current_org.id)
    else
      relation
    end
  end

  def default_url_options
    opts = super || {}
    # The `(:org_slug)` leading segment is optional in the route table. Without a
    # default for it, Rails binds the first positional argument to :org_slug
    # instead of the real key, so every helper called from a view would raise:
    #
    #   No route matches {org_slug: #<App ...>, app_id: #<DebugFile ...>}
    #
    # A request with no organization prefix must generate URLs with no prefix,
    # so the default belongs here regardless of whether Pro is loaded. Only the
    # *resolved* slug depends on the tenant machinery below.
    opts = opts.merge(org_slug: nil) unless opts.key?(:org_slug)
    return opts unless defined?(Zealot::Pro)

    org = (current_org rescue nil) if respond_to?(:current_org)
    slug = org&.slug
    is_default = (org.respond_to?(:default?) && org.default?) || slug == 'default'

    if slug.present? && !is_default
      opts.merge(org_slug: slug)
    else
      opts.merge(org_slug: nil)
    end
  end

  private

  def set_current_tenant
    Current.organization = resolve_organization
    Current.user = current_user if respond_to?(:current_user)
  end

  def resolve_organization
    user = current_user rescue nil
    Zealot::Resolvers::OrganizationResolver.resolve(
      request: request,
      user: user
    )
  end
end
