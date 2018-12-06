class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, to: :crud
    if user.admin?
      can :manage, Activity
      can :manage, ActivityType
      can :manage, ActivityCategory
      can :manage, Alert
      can :manage, Contact
      can :manage, Calendar
      can :manage, CalendarEvent
      can :manage, Scoreboard
      can :manage, School
      can :manage, SchoolGroup
      can :manage, User
      can :manage, DataFeed
      can :manage, Meter
      can :manage, Simulation
    elsif user.school_admin?
      can :manage, Activity, school_id: user.school_id
      can :manage, Calendar, id: user.school.try(:calendar_id)
      can :manage, CalendarEvent, calendar_id: user.school.try(:calendar_id)

      can [:update, :manage_school_times, :suggest_activity], School, id: user.school_id
      can [:read, :usage, :awards], School do |school|
        school.active? || user.school_id == school.id
      end
      can :manage, Alert, school_id: user.school_id
      can :manage, Contact, school_id: user.school_id
      can :crud, Meter, school_id: user.school_id
      can :activate, Meter, active: false, school_id: user.school_id
      can :deactivate, Meter, active: true, school_id: user.school_id
      can :read, ActivityCategory
      can :show, ActivityType
      can :show, Scoreboard
    elsif user.school_user?
      can :manage, Activity, school: { id: user.school_id, active: true }
      can :index, School
      can :show, School, active: true
      can :usage, School, active: true
      can :awards, School, active: true
      can :suggest_activity, School, active: true, id: user.school_id
      can :read, ActivityCategory
      can :show, ActivityType
      can :show, Scoreboard
    elsif user.guest?
      can :read, Activity, school: { active: true }
      can :read, ActivityCategory
      can :show, ActivityType
      can :index, School
      can :awards, School, active: true
      can :show, School, active: true
      can :usage, School, active: true
      can :show, Scoreboard
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
