class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, to: :crud
    if user.admin?
      can :manage, :all
    elsif user.school_admin?
      can :manage, Activity, school_id: user.school_id
      can :crud, Calendar, id: user.school.try(:calendar_id)
      can :manage, CalendarEvent, calendar_id: user.school.try(:calendar_id)
      can [:update, :manage_school_times, :suggest_activity], School, id: user.school_id
      can [:read, :usage, :awards], School do |school|
        school.active? || user.school_id == school.id
      end
      can :index, AlertSubscriptionEvent, school_id: user.school_id
      can :manage, Contact, school_id: user.school_id
      can [:index, :create, :read, :update], Meter, school_id: user.school_id
      can :activate, Meter, active: false, school_id: user.school_id
      can :deactivate, Meter, active: true, school_id: user.school_id
      can [:destroy, :delete], Meter do |meter|
        meter.school_id == user.school_id && meter.amr_data_feed_readings.count == 0
      end
      can :read, ActivityCategory
      can :show, ActivityType
      can :show, Scoreboard
      can :manage, SchoolOnboarding do |onboarding|
        onboarding.created_user == user
      end
      can :read, FindOutMore
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
      can :read, FindOutMore
    elsif user.guest?
      can :read, Activity, school: { active: true }
      can :read, ActivityCategory
      can :show, ActivityType
      can :index, School
      can :awards, School, active: true
      can :show, School, active: true
      can :usage, School, active: true
      can :show, Scoreboard
      can :manage, SchoolOnboarding, created_user_id: nil
      can :read, FindOutMore
    elsif user.school_onboarding?
      can :manage, SchoolOnboarding do |onboarding|
        onboarding.created_user == user
      end
      can :read, Activity, school: { active: true }
      can :read, ActivityCategory
      can :show, ActivityType
      can :index, School
      can :awards, School, active: true
      can :show, School, active: true
      can :usage, School, active: true
      can :show, Scoreboard
    end
  end
end
