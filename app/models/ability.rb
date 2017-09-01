class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, Activity
      can :manage, ActivityType
      can :manage, ActivityCategory
      can :manage, Calendar
      can :manage, School
      can :manage, User
    elsif user.school_admin?
      can :manage, Activity, school_id: user.school_id
#      can :manage, Calendar, id: user.school.try(:calendar_id)
      can :index, School
      can :show, School
      can :usage, School
      can :awards, School
      can :scoreboard, School
      can :manage, Activity, school_id: user.school_id
      can :read, ActivityCategory
      can :show, ActivityType
    elsif user.guest?
      can :show, Activity
      can :read, ActivityCategory
      can :show, ActivityType
      can :index, School
      can :awards, School
      can :scoreboard, School
      can :show, School
      can :usage, School
    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
