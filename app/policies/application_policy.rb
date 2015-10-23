class ApplicationPolicy
  attr_reader :user, :record

  # class << self
  #   def actions
  #     @actions ||= []
  #   end
  #
  #   def permit(action_or_actions)
  #     acts = Array(action_or_actions).collect(&:to_s)
  #     acts.each do |act|
  #       define_method("#{actioactn}?") { can? act }
  #     end
  #     actions.concat(acts)
  #   end
  #
  #   private
  #     def can?(method_name)
  #       permission = {
  #         action: action,
  #         resource: record.is_a?(Class) ? record.name : record.class.name
  #       }
  #
  #       user.permissions.exist?(permissions)
  #     end
  # end

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
