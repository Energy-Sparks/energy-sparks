class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, to: :crud

    # all users can do these things
    can :read, Activity, school: { visible: true }
    can [:read, :recommended], ActivityCategory
    can [:read, :recommended], InterventionTypeGroup
    can [:read, :search], InterventionType
    can [:read, :search], ActivityType

    can :read, SchoolGroup
    can :compare, SchoolGroup, public: true

    can :index, School
    can [
      :show, :usage, :show_pupils_dash, :suggest_activity
    ], School, visible: true, public: true

    can :live_data, Cad, visible: true, public: true
    can :read, Scoreboard, public: true

    can :read, FindOutMore
    can :read, Observation
    can :read, TransportSurvey
    can :read, TransportSurveyResponse
    can :read, ProgrammeType
    can :read_dashboard_menu, School

    can :show, SchoolTarget
    can :index, SchoolTarget

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
        can :compare, SchoolGroup, id: user.school_group_id

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
          onboarding.created_user.blank? || (onboarding.created_user == user)
        end
        can :read, [:my_school_menu, :school_downloads]
        can :switch, School
      end
      #allow users from schools in same group to access dashboards
      if user.school.present?
        can [:show, :usage, :show_pupils_dash], School, { school_group_id: user.school.school_group_id, visible: true }
        can :compare, SchoolGroup, { id: user.school.school_group_id, public: false }
      end
      can [
        :show, :usage, :show_pupils_dash,
        :update, :manage_school_times, :suggest_activity, :manage_users,
        :show_management_dash,
        :read, :start_programme, :read_restricted_analysis
      ], School, school_scope
      can :manage, EstimatedAnnualConsumption, related_school_scope
      can :manage, SchoolTarget, related_school_scope
      can :manage, Activity, related_school_scope
      can :manage, Contact, related_school_scope
      can :manage, UserTariff, related_school_scope
      can :show, Cad, related_school_scope
      can :read, Scoreboard, public: false, id: user.default_scoreboard.try(:id)
      can [:index, :create, :read, :update], ConsentDocument, related_school_scope
      can [:index, :read], ConsentGrant, related_school_scope
      can [:index, :create, :read, :update], Meter, related_school_scope
      can :activate, Meter, { active: false }.merge(related_school_scope)
      can :deactivate, Meter, { active: true }.merge(related_school_scope)
      can [:destroy, :delete], Meter, related_school_scope
      cannot [:destroy, :delete], Meter do |meter|
        meter.amr_data_feed_readings.count > 0
      end
      can :manage, Observation, related_school_scope
      can :manage, TransportSurvey, related_school_scope
      can :manage, TransportSurveyResponse, transport_survey: related_school_scope
      can :crud, Programme, related_school_scope

      can [:manage, :enable_alerts], User, related_school_scope

      can [:manage, :enable_alerts], User do |other_user|
        other_user.cluster_schools.include?(user.school)
      end

      cannot :delete, User do |other_user|
        user.id == other_user.id
      end

      can [:show, :read, :index], Audit, related_school_scope
    elsif user.staff? || user.volunteer? || user.pupil?
      #abilities that give you access to dashboards for own school
      school_scope = { id: user.school_id, visible: true }
      can [
        :show, :usage, :show_pupils_dash, :suggest_activity
      ], School, school_scope
      #they can also do these things for schools in same group
      can [
        :show, :usage, :show_pupils_dash, :suggest_activity
      ], School, { school_group_id: user.school.school_group_id, visible: true }
      can [:show, :read, :index], Audit, school: { id: user.school_id, visible: true }
      can :compare, SchoolGroup, { id: user.school.school_group_id }
      can :manage, Activity, school: { id: user.school_id, visible: true }
      can :manage, Observation, school: { id: user.school_id, visible: true }
      can :read, Scoreboard, public: false, id: user.default_scoreboard.try(:id)
      can :read, [:my_school_menu, :school_downloads]
      can :read, Meter
      can [:start_programme], School, id: user.school_id, visible: true
      #pupils can view management dashboard for their school and others in group
      if user.pupil?
        can :show_management_dash, School, id: user.school_id, visible: true
        can :show_management_dash, School, { school_group_id: user.school.school_group_id, visible: true }
        can [:start, :read, :update, :create], TransportSurvey, related_school_scope
        can [:read, :create], TransportSurveyResponse, transport_survey: related_school_scope
      end
      #pupils and volunteers can only read real cost data if their school is public
      if user.volunteer? || user.pupil?
        can :read_restricted_analysis, School, { id: user.school_id, visible: true, public: true }
      else
        #but staff can read it regardless
        can :read_restricted_analysis, School, { id: user.school_id, visible: true }
      end
      if user.staff? || user.volunteer?
        can :manage, SchoolTarget, school: { id: user.school_id, visible: true }
        can :manage, EstimatedAnnualConsumption, school: { id: user.school_id, visible: true }
        can [:show_management_dash], School, id: user.school_id, visible: true
        can [:show_management_dash, :start_programme], School, { school_group_id: user.school.school_group_id, visible: true }
        can :crud, Programme, school: { id: user.school_id, visible: true }
        can :enable_alerts, User, id: user.id
        can [:create, :update, :destroy], Contact, user_id: user.id
        can :manage, TransportSurvey, school: { id: user.school_id, visible: true }
        can :manage, TransportSurveyResponse, transport_survey: { school: { id: user.school_id, visible: true } }
      end
    elsif user.guest?
      can :manage, SchoolOnboarding, created_user_id: nil
    elsif user.school_onboarding?
      can :manage, SchoolOnboarding do |onboarding|
        onboarding.created_user == user || onboarding.created_user.nil?
      end
    end
  end
end
