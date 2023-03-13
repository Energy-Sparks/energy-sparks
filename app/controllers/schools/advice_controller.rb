module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    before_action :load_advice_pages
    before_action :set_tab_name
    before_action :set_content

    include DashboardAlerts
    include DashboardPriorities

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
      @management_priorities = sort_priorities
    end

    def alerts
      @dashboard_alerts = setup_alerts(latest_dashboard_alerts, :management_dashboard_title, limit: nil)
    end

    private

    def set_tab_name
      @tab = action_name.to_sym
    end

    def load_advice_pages
      @advice_pages = AdvicePage.all
    end

    def set_content
      @priority_count = latest_management_priorities.count
      @alert_count = latest_dashboard_alerts.count
    end

    def latest_dashboard_alerts
      @latest_dashboard_alerts ||= @school.latest_dashboard_alerts.management_dashboard
    end

    def latest_management_priorities
      @latest_management_priorities ||= @school.latest_management_priorities
    end

    def sort_priorities
      setup_priorities(latest_management_priorities, limit: nil).sort do |a, b|
        money_to_i(b.template_variables[:average_one_year_saving_gbp]) <=> money_to_i(a.template_variables[:average_one_year_saving_gbp])
      end
    end

    def money_to_i(val)
      val.gsub(/\D/, '').to_i
    end
  end
end
