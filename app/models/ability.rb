class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, to: :crud

    can :analyse, :all
    cannot :analyse, :test
    cannot :analyse, :heating_model_fitting

    if user.admin?
      can :manage, :all
      can :analyse, :test
      can :analyse, :heating_model_fitting
    elsif user.school_admin?
      can :manage, Activity, school_id: user.school_id
      can :crud, Calendar, id: user.school.try(:calendar_id)
      can :manage, CalendarEvent, calendar_id: user.school.try(:calendar_id)
      can [:update, :manage_school_times, :suggest_activity], School, id: user.school_id
      can [:read, :usage], School do |school|
        school.active? || user.school_id == school.id
      end
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
      can :manage, Observation
      can :crud, Programme, school_id: user.school_id
      can :start_programme, School, id: user.school_id
      can :read, ProgrammeType
    elsif user.school_user?
      can :manage, Activity, school: { id: user.school_id, active: true }
      can :index, School
      can :show, School, active: true
      can :usage, School, active: true
      can :suggest_activity, School, active: true, id: user.school_id
      can :read, ActivityCategory
      can :show, ActivityType
      can :show, Scoreboard
      can :read, FindOutMore
      can :manage, Observation
      can :crud, Programme, school_id: user.school_id
      can :start_programme, School, id: user.school_id
      can :read, ProgrammeType
    elsif user.guest?
      cannot :analyse, :cost
      can :read, Activity, school: { active: true }
      can :read, ActivityCategory
      can :show, ActivityType
      can :index, School
      can :show, School, active: true
      can :usage, School, active: true
      can :show, Scoreboard
      can :manage, SchoolOnboarding, created_user_id: nil
      can :read, FindOutMore
      can :read, Observation
      can :read, Programme, school_id: user.school_id
      can :read, ProgrammeType
    elsif user.school_onboarding?
      cannot :analyse, :cost
      can :manage, SchoolOnboarding do |onboarding|
        onboarding.created_user == user
      end
      can :read, Activity, school: { active: true }
      can :read, ActivityCategory
      can :show, ActivityType
      can :index, School
      can :show, School, active: true
      can :usage, School, active: true
      can :show, Scoreboard
    end
  end
end
