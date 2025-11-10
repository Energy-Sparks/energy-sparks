# frozen_string_literal: true

module SchoolGroups
  class SchoolEngagementController < BaseController
    include Columns
    include ApplicationHelper

    def self.show?(user)
      user.admin? || user.group_admin?
    end

    def index
      raise CanCan::AccessDenied unless self.class.show?(current_user)

      build_breadcrumbs([name: I18n.t('school_groups.sub_nav.school_engagement')])
      @rows = Schools::EngagedSchoolService.list_schools(false, @school_group.id, only_data_enabled: true)
      @columns = [Column.new(I18n.t('common.school'),
                             ->(service) { service.school.name }),
                  Column.new(I18n.t('school_statistics.school_type'),
                             ->(service) { service.school.school_type&.humanize }),
                  Column.new(I18n.t('common_nav_bar_menus.activities'),
                             ->(service) { service.recent_activity_count }),
                  Column.new(I18n.t('common_nav_bar_menus.actions'),
                             ->(service) { service.recent_action_count }),
                  Column.new(I18n.t('common.programmes'),
                             ->(service) { service.recently_enrolled_programme_count }),
                  Column.new(I18n.t('school_groups.school_engagement.energy_saving_target'),
                             ->(service) { y_n(service.active_target?) }),
                  Column.new(I18n.t('school_groups.school_engagement.completed_transport_survery'),
                             ->(service) { y_n(service.transport_surveys?) }),
                  Column.new(I18n.t('school_groups.school_engagement.recorded_temperatures'),
                             ->(service) { y_n(service.temperature_recordings?) }),
                  Column.new(I18n.t('school_groups.school_engagement.received_an_audit'),
                             ->(service) { y_n(service.audits?) }),
                  Column.new(I18n.t('school_groups.school_engagement.active_users'),
                             ->(service) { service.recently_logged_in_user_count }),
                  Column.new(I18n.t('school_groups.school_engagement.last_visit'),
                             ->(service) { service.most_recent_login&.to_date&.iso8601 },
                             ->(service) { service.most_recent_login&.to_date&.to_fs(:es_compact) })]
      respond_to do |format|
        format.html
        format.csv { send_data csv_report(@columns, @rows), filename: EnergySparks::Filenames.csv('school-engagement') }
      end
    end
  end
end
