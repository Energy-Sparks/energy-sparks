class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, to: :crud

    # enable all analysis, but disable known admin ones
    can :analyse, :all
    cannot :analyse, :test
    cannot :analyse, :heating_model_fitting

    # all users can do these things
    can :read, Activity, school: { active: true }
    can :read, ActivityCategory
    can :show, ActivityType
    can :index, School
    can :show, School, active: true
    can :usage, School, active: true
    can :show, Scoreboard
    can :read, FindOutMore
    can :read, Observation
    can :read, ProgrammeType

    if user.admin?
      can :manage, :all
      can :analyse, :test
      can :analyse, :heating_model_fitting
    elsif user.school_admin?
      can :manage, Activity, school_id: user.school_id
      can :crud, Calendar, id: user.school.try(:calendar_id)
      can :manage, CalendarEvent, calendar_id: user.school.try(:calendar_id)
      can [:update, :manage_school_times, :suggest_activity, :manage_users, :show_teachers_dash, :show_pupils_dash], School, id: user.school_id
      can [:read, :usage], School do |school|
        user.school_id == school.id
      end
      can :manage, Contact, school_id: user.school_id
      can [:index, :create, :read, :update], Meter, school_id: user.school_id
      can :activate, Meter, active: false, school_id: user.school_id
      can :deactivate, Meter, active: true, school_id: user.school_id
      can [:destroy, :delete], Meter do |meter|
        meter.school_id == user.school_id && meter.amr_data_feed_readings.count == 0
      end
      can :manage, SchoolOnboarding do |onboarding|
        onboarding.created_user == user
      end
      can :manage, Observation, school_id: user.school_id
      can :crud, Programme, school_id: user.school_id
      can :start_programme, School, id: user.school_id
      can :manage, User, school_id: user.school_id
      cannot :delete, User do |other_user|
        user.id == other_user.id
      end
    elsif user.staff? || user.pupil?
      can :manage, Activity, school: { id: user.school_id, active: true }
      can [:show_pupils_dash, :suggest_activity], School, id: user.school_id, active: true
      can :manage, Observation, school: { id: user.school_id, active: true }
      if user.staff?
        can [:show_teachers_dash, :start_programme], School, id: user.school_id, active: true
        can :crud, Programme, school: { id: user.school_id, active: true }
        can :enable_alerts, User, id: user.id
        can [:create, :update, :destroy], Contact, user_id: user.id
      end
    elsif user.guest?
      cannot :analyse, :cost
      can :manage, SchoolOnboarding, created_user_id: nil
    elsif user.school_onboarding?
      cannot :analyse, :cost
      can :manage, SchoolOnboarding do |onboarding|
        onboarding.created_user == user
      end
    end
  end
end
