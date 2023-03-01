module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    before_action :load_advice_pages
    before_action :set_tab_name

    include SchoolAggregation
    include DashboardAlerts

    def show
      @management_priorities = @school.latest_management_priorities.by_priority.limit(site_settings.management_priorities_page_limit).map do |priority|
        TemplateInterpolation.new(
          priority.content_version,
          with_objects: { find_out_more: priority.find_out_more },
          proxy: [:colour]
        ).interpolate(
          :management_priorities_title,
          with: priority.alert.template_variables
        )
      end

      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.management_dashboard, :management_dashboard_title, limit: nil)
    end

    def priorities
      @management_priorities = @school.latest_management_priorities.by_priority.limit(site_settings.management_priorities_page_limit).map do |priority|
        TemplateInterpolation.new(
          priority.content_version,
          with_objects: { find_out_more: priority.find_out_more },
          proxy: [:colour]
        ).interpolate(
          :management_priorities_title,
          with: priority.alert.template_variables
        )
      end
    end

    def alerts
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.management_dashboard, :management_dashboard_title, limit: nil)
    end

    private

    def set_tab_name
      @tab = action_name.to_sym
    end

    def load_advice_pages
      @advice_pages = AdvicePage.all.by_key
    end
  end
end
