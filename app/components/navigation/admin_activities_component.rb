# frozen_string_literal: true

module Navigation
  class AdminActivitiesComponent < BaseComponent
    def activities_section
      [
        { name: 'Activities', path: admin_activity_types_path },
        { name: 'Categories', path: admin_activity_categories_path },
        { name: 'Latest Recordings', path: admin_reports_activities_path },
        { name: 'Report', path: admin_reports_activity_types_path }
      ]
    end

    def actions_section
      [
        { name: 'Actions', path: admin_intervention_types_path },
        { name: 'Categories', path: admin_intervention_type_groups_path },
        { name: 'Latest Recordings', path: admin_reports_interventions_path },
        { name: 'Report', path: admin_reports_intervention_types_path }
      ]
    end

    def related_section
      [
        { name: 'Advice pages', path: admin_advice_pages_path },
        { name: 'Alerts', path: admin_alert_types_path },
        { name: 'Audits', path: admin_reports_recent_audits_path },
        { name: 'Programmes', path: admin_programme_types_path },
        { name: 'Recent images', path: admin_reports_images_path }
      ]
    end
  end
end
