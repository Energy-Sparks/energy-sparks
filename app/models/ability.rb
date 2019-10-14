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

    can :manage, Location, school_id: user.school_id

    if user.guest?
      cannot :manage, Location
      can :read, Location
    end

    if user.admin?
      can :manage, :all
      can :analyse, :test
      can :analyse, :heating_model_fitting
      cannot :read, :school_menu
    elsif user.school_admin? || user.group_admin?
      if user.group_admin?
        school_scope = { school_group_id: user.school_group_id }
        related_school_scope = { school: { school_group_id: user.school_group_id } }
        can :show, SchoolGroup, id: user.school_group_id
        can [:show, :update], Calendar do |calendar|
          user.school_group.calendars.include?(calendar)
        end
        can :manage, CalendarEvent do |calendar_event|
          user.school_group.calendars.include?(calendar_event.calendar)
        end
      else
        school_scope = { id: user.school_id }
        related_school_scope = { school_id: user.school_id }
        can [:show, :update], Calendar, id: user.school.try(:calendar_id)
        can :manage, CalendarEvent, calendar_id: user.school.try(:calendar_id)
        can :manage, SchoolOnboarding do |onboarding|
          onboarding.created_user == user
        end
        can :read, :school_menu
        can :read, :dashboard_menu
      end
      can [
        :update, :manage_school_times, :suggest_activity, :manage_users,
        :show_teachers_dash, :show_pupils_dash, :show_management_dash,
        :read, :usage, :start_programme
      ], School, school_scope
      can :manage, Activity, related_school_scope
      can :manage, Contact, related_school_scope
      can [:index, :create, :read, :update], Meter, related_school_scope
      can :activate, Meter, { active: false }.merge(related_school_scope)
      can :deactivate, Meter, { active: true }.merge(related_school_scope)
      can [:destroy, :delete], Meter, related_school_scope
      cannot [:destroy, :delete], Meter do |meter|
        meter.amr_data_feed_readings.count > 0
      end
      can :manage, Observation, related_school_scope
      can :crud, Programme, related_school_scope
      can [:manage, :enable_alerts], User, related_school_scope
      cannot :delete, User do |other_user|
        user.id == other_user.id
      end
    elsif user.staff? || user.pupil?
      can :manage, Activity, school: { id: user.school_id, active: true }
      can [:show_pupils_dash, :suggest_activity], School, id: user.school_id, active: true
      can :manage, Observation, school: { id: user.school_id, active: true }
      if user.staff?
        can [:show_teachers_dash, :show_management_dash, :start_programme], School, id: user.school_id, active: true
        can :crud, Programme, school: { id: user.school_id, active: true }
        can :enable_alerts, User, id: user.id
        can [:create, :update, :destroy], Contact, user_id: user.id
        can :read, :school_menu
        can :read, :dashboard_menu
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
