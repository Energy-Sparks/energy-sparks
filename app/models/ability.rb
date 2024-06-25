# CANCAN DEFAULTS
#
# CanCan has some default aliases and matchers:
#
# :all matches any object
# :manage matches any action
# :read is an alias for [:index, :show]
#
# CUSTOM ALIASES
#
# We alias :create, :read, :update, :destroy to :crud
#
# CUSTOM OBJECTS
#
# We use some symbols to refer to things which don't otherwise have a model to refer to.
# These are generally used for admin specific functionality and generally with just :manage or
# :show as an action
#
# :admin_functions - Admin specific pages
# :all_schools - All schools on site, include those that arenot visible
# :funders - all funders
# :geocoding - Geocoding/location objects on school details form
# :parent_calendars - Parent calendars
# :read_invisible_schools - whether to show invisible schools on school index page. Admin only
#
# CUSTOM CONTROLLER ACTIONS
#
# When we call `load_and_authorize_resource` in a controller CanCan will check whether the user can access
# the controller action before it is called. This includes not only the CRUD methods but also any custom
# method.
#
# So, for example, in order for any user to be able to access the ActivityType search page we need to grant:
#
# ```
# can :search, ActivityType
# ```
#
# So some of the actions given below actually map to controller actions. But others are custom actions used in
# specific parts of the code, usually in controllers or templates to manage access to other fine-grained functionality
#
# SCHOOLS AND GROUP CUSTOM ACTIONS
#
# :change_data_enabled - can enable/disable data enabled features for a school. Admin only
# :change_data_processing - can enabled/disable data processing. Admin only
# :change_public - can make school public or private. Admin only
# :change_visibility - can change visibility of school. Admin only
# :configure - can update configuration for a school. Admin only
# :download_school_data - can download school meter and related data
# :expert_analyse - can access internal 'expert analysis' pages. Admin only
# :manage_users - can manage users
# :manage_solar_feed_configuration - can manage solar data feeds. Admin only
# :manage_school_times - can manage school open/close times
# :read_dashboard_menu - can see pupil/adult dashboard buttons on school pages.
# :regenerate_school_data - can access functionality to regenerate a school. Admin only
# :remove_school - can remove/archive a School. Admin only
#
# :show_management_dash - whether to show prompts and messages on dashboard (see Promptable), whether to
# show print view, plus whether to show other data enabled features on school dashboards. Access to dashboard itself is
# covered by :show
#
# :show_pupils_dash - can view pupil dashboard. Adult dashboard just uses :show
# :start_programme - can start a programme for a school.
# :suggest_activity - whether to show button to suggest next activity. Obsolete?
# :validate_meters - can validate meter data for a school. Admin only
# :view_advice_pages - can access old analysis pages. Admin only
# :view_content_reports - can view admin only reports from overnight jobs
# :view_dcc_data - can view DCC debug detail for school meters. Admin only
# :view_target_data - can see debug for targets feature. Admin only
#
# SCHOOL GROUP ACTIONS
#
# :compare - can compare schools in this group. Used to add/remove links to compare functionality
# But also used to control access to school group page with data.
# :update_settings - can use manage settings (chart prefs, clusters) for school group. But also used to gate
# access to viewing clusters on school group dashboard. Also used to decide whether to show sub navbar on some pages
#
# METERS
#
# :grant_consent - can grant consent for a meter. Admin only
# :report_on - can view data report for a Meter. Admin only
# :view_inventory - can view DCC meter inventory. Admin only
# :view_meter_attributes - can view meter attributes for a Meter. Admin only
# :view_tariff_reports - can view summary of tariffs for a meter. Admin only
# :withdraw_consent - can withdrawn consent for a meter. Admin only
#
# Other objects and functionality is covered by the CanCan default operations, e.g. CRUD, show, index, manage
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, to: :crud

    # All users can do these things
    can :read, Activity, school: { visible: true }
    can [:read, :recommended], ActivityCategory
    can [:read, :recommended], InterventionTypeGroup
    can [:read, :search, :for_school], InterventionType
    can [:read, :search, :for_school], ActivityType

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
    can :read, TransportSurvey::Response
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
        related_school_scope = { school: { school_group_id: user.school_group_id } }
        can :show, SchoolGroup, id: user.school_group_id
        can :compare, SchoolGroup, id: user.school_group_id
        can :show_management_dash, SchoolGroup, id: user.school_group.id
        can :update_settings, SchoolGroup, id: user.school_group_id
        can :manage, SchoolGroupCluster, school_group_id: user.school_group_id
        can :manage, EnergyTariff, tariff_holder: user.school_group

        can :manage, EnergyTariff, related_school_scope

        can [:show, :update], Calendar do |calendar|
          user.school_group.calendars.include?(calendar)
        end
        can :manage, CalendarEvent do |calendar_event|
          user.school_group.calendars.include?(calendar_event.calendar)
        end
        # A group admin can manage onboarding for any school in their group
        # The onboarding must be associated with the group
        can :manage, SchoolOnboarding do |onboarding|
          onboarding.school_group.present? && user.school_group == onboarding.school_group
        end
      else
        school_scope = { id: user.school_id, visible: true }
        related_school_scope = { school_id: user.school_id }
        can [:show, :update], Calendar, id: user.school.try(:calendar_id)
        can :manage, CalendarEvent, calendar_id: user.school.try(:calendar_id)
        can :manage, SchoolOnboarding do |onboarding|
          onboarding.created_user.blank? || (onboarding.created_user == user)
        end
        can :read, [:my_school_menu]
        can :switch, School
        can :manage, EnergyTariff, tariff_holder: user.school
      end
      # allow users from schools in same group to access dashboards
      if user.school.present?
        can [:show, :usage, :show_pupils_dash], School, { school_group_id: user.school.school_group_id, visible: true }
        can :compare, SchoolGroup, { id: user.school.school_group_id, public: false }
        can :show_management_dash, SchoolGroup, { id: user.school.school_group_id }
      end
      can [
        :show, :usage, :show_pupils_dash,
        :update, :manage_school_times, :suggest_activity, :manage_users,
        :show_management_dash,
        :read, :start_programme, :read_restricted_analysis, :read_restricted_advice
      ], School, school_scope
      can :manage, EstimatedAnnualConsumption, related_school_scope
      can :manage, SchoolTarget, related_school_scope
      can :manage, Activity, related_school_scope
      can :manage, Contact, related_school_scope
      can :show, Cad, related_school_scope
      can :read, Scoreboard, public: false, id: user.default_scoreboard.try(:id)
      can [:index, :create, :read, :update], ConsentDocument, related_school_scope
      can [:index, :read], ConsentGrant, related_school_scope
      can [:index, :create, :read, :update], Meter, related_school_scope
      can :activate, Meter, { active: false }.merge(related_school_scope)
      can :deactivate, Meter, { active: true }.merge(related_school_scope)
      can [:destroy, :delete], Meter, related_school_scope
      cannot [:destroy, :delete], Meter do |meter|
        meter.amr_data_feed_readings.any?
      end
      can :manage, Observation, related_school_scope
      can :manage, TransportSurvey, related_school_scope
      can :manage, TransportSurvey::Response, transport_survey: related_school_scope
      can :crud, Programme, related_school_scope

      can [:manage, :enable_alerts], User, related_school_scope

      can [:manage, :enable_alerts], User do |other_user|
        other_user.cluster_schools.include?(user.school)
      end

      cannot :delete, User do |other_user|
        user.id == other_user.id
      end

      can [:show, :read, :index], Audit, related_school_scope
      can :download_school_data, School, school_scope
    elsif user.staff? || user.volunteer? || user.pupil?
      # abilities that give you access to dashboards for own school
      school_scope = { id: user.school_id, visible: true }
      can [
        :show, :usage, :show_pupils_dash, :suggest_activity
      ], School, school_scope
      # they can also do these things for schools in same group
      can [
        :show, :usage, :show_pupils_dash, :suggest_activity
      ], School, { school_group_id: user.school.school_group_id, visible: true }
      can [:show, :read, :index], Audit, school: { id: user.school_id, visible: true }
      can :compare, SchoolGroup, { id: user.school.school_group_id }
      can :show_management_dash, SchoolGroup, { id: user.school.school_group_id }

      can :manage, Activity, school: { id: user.school_id, visible: true }
      can :manage, Observation, school: { id: user.school_id, visible: true }
      can :read, Scoreboard, public: false, id: user.default_scoreboard.try(:id)
      can :read, [:my_school_menu]
      can :download_school_data, School, school_scope
      can :read, Meter
      can [:start_programme], School, id: user.school_id, visible: true
      # pupils can view management dashboard for their school and others in group
      if user.pupil?
        can :show_management_dash, School, id: user.school_id, visible: true
        can :show_management_dash, School, { school_group_id: user.school.school_group_id, visible: true }
        can [:start, :read, :update, :create], TransportSurvey, related_school_scope
        can [:read, :create], TransportSurvey::Response, transport_survey: related_school_scope
      end
      # pupils and volunteers can only read real cost data if their school is public
      if user.volunteer? || user.pupil?
        can :read_restricted_analysis, School, { id: user.school_id, visible: true, public: true }
        can :read_restricted_advice, School, { id: user.school_id, visible: true, public: true }
      else
        # but staff can read it regardless
        can :read_restricted_analysis, School, { id: user.school_id, visible: true }
        can :read_restricted_advice, School, { id: user.school_id, visible: true }
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
        can :manage, TransportSurvey::Response, transport_survey: { school: { id: user.school_id, visible: true } }
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
