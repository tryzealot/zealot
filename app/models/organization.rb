# frozen_string_literal: true

class Organization
  attr_reader :id, :name, :slug

  def initialize(id = 0, name = 'Default', slug = 'default', **kwargs)
    if id.is_a?(Hash)
      kwargs = id.merge(kwargs)
      id = 0
    end

    @id   = kwargs[:id] || id
    @name = kwargs[:name] || name
    @slug = kwargs[:slug] || slug
  end

  def users
    User.all
  end

  def persisted?
    false
  end

  def default?
    slug == 'default'
  end

  def ==(other)
    other.is_a?(Organization) && (id == other.id || slug == other.slug)
  end
  alias eql? ==

  def hash
    [id, slug].hash
  end
end
