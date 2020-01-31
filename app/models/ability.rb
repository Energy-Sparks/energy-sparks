class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, to: :crud

    # all users can do these things
    can :read, Activity, school: { visible: true }
    can :read, ActivityCategory
    can :show, ActivityType
    can :index, School
    can :read, SchoolGroup
    can :show, School, visible: true
    can :usage, School, visible: true
    can :read, Scoreboard
    can :read, FindOutMore
    can :read, Observation
    can :read, ProgrammeType

    can :manage, Location, school_id: user.school_id

    if user.guest?
      cannot :manage, Location
      can :read, Location
    end

    if user.admin? || user.analytics?
      can :manage, :all
      cannot :read, :my_school_menu
    elsif user.school_admin? || user.group_admin?
      if user.group_admin?
        school_scope = { school_group_id: user.school_group_id, visible: true }
        related_school_scope = { school: { school_group_id: user.school_group_id, visible: true } }
        can :show, SchoolGroup, id: user.school_group_id
        can [:show, :update], Calendar do |calendar|
          user.school_group.calendars.include?(calendar)
        end
        can :manage, CalendarEvent do |calendar_event|
          user.school_group.calendars.include?(calendar_event.calendar)
        end
      else
        school_scope = { id: user.school_id, visible: true }
        related_school_scope = { school_id: user.school_id }
        can [:show, :update], Calendar, id: user.school.try(:calendar_id)
        can :manage, CalendarEvent, calendar_id: user.school.try(:calendar_id)
        can :manage, SchoolOnboarding do |onboarding|
          onboarding.created_user == user
        end
        can :read, [:my_school_menu, :school_downloads]
      end
      can [
        :update, :manage_school_times, :suggest_activity, :manage_users,
        :show_teachers_dash, :show_pupils_dash, :show_management_dash,
        :read, :usage, :start_programme, :read_dashboard_menu, :read_restricted_analysis
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
      can :manage, Activity, school: { id: user.school_id, visible: true }
      can [:show_pupils_dash, :suggest_activity], School, id: user.school_id, visible: true
      can :manage, Observation, school: { id: user.school_id, visible: true }
      can :read_restricted_analysis, School, school_scope
      can :read, [:my_school_menu, :school_downloads]
      can :read, Meter
      if user.staff?
        can [:show_teachers_dash, :show_management_dash, :start_programme, :read_dashboard_menu], School, id: user.school_id, visible: true
        can :crud, Programme, school: { id: user.school_id, visible: true }
        can :enable_alerts, User, id: user.id
        can [:create, :update, :destroy], Contact, user_id: user.id
      end
    elsif user.guest?
      can :manage, SchoolOnboarding, created_user_id: nil
    elsif user.school_onboarding?
      can :manage, SchoolOnboarding do |onboarding|
        onboarding.created_user == user
      end
    end
  end
end
