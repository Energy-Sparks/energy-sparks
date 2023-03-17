module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    before_action :load_advice_pages
    before_action :set_tab_name
    before_action :set_content
    before_action :set_breadcrumbs

    include DashboardAlerts
    include DashboardPriorities

    def show
      @advice_page_benchmarks = @school.advice_page_school_benchmarks
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

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('advice_pages.breadcrumbs.root'), href: school_advice_path(@school) }]
      case @tab
      when :alerts
        @breadcrumbs << {
          name: I18n.t('advice_pages.index.alerts.title'), href: alerts_school_advice_path(@school)
        }
      when :priorities
        @breadcrumbs << {
          name: I18n.t('advice_pages.index.priorities.title'), href: alerts_school_advice_path(@school)
        }
      end
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
