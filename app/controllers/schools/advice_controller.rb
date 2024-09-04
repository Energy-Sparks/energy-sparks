module Schools
  class AdviceController < ApplicationController
    include NonPublicSchools
    include DashboardAlerts
    include DashboardPriorities
    include SchoolInactive
    include SchoolAggregation

    load_resource :school
    skip_before_action :authenticate_user!
    before_action { redirect_unless_permitted :show } # redirect to login if user can't view the school
    before_action :school_inactive
    before_action :load_advice_pages
    before_action :set_tab_name
    before_action :set_counts
    before_action :set_breadcrumbs

    before_action :check_aggregated_school_in_cache, only: [:show]

    def show
      if Flipper.enabled?(:new_dashboards_2024, current_user)
        @audience = :adult
        if can_benchmark_electricity?
          @electricity_annual_usage = electricity_usage_service.annual_usage
          @electricity_benchmarked_usage = electricity_usage_service.benchmark_usage
        end

        if can_benchmark_gas?
          @gas_annual_usage = gas_usage_service.annual_usage
          @gas_benchmarked_usage = gas_usage_service.benchmark_usage
        end

        render :new_show, layout: 'dashboards'
      else
        @advice_page_benchmarks = @school.advice_page_school_benchmarks
        render :show
      end
    end

    def priorities
      @management_priorities = sort_priorities
    end

    def alerts
      @dashboard_alerts = setup_alerts(latest_dashboard_alerts, :management_dashboard_title, limit: nil)
    end

    private

    def can_benchmark_electricity?
      @school.has_electricity? && electricity_usage_service.enough_data?
    end

    def can_benchmark_gas?
      @school.has_gas? && gas_usage_service.enough_data?
    end

    def gas_usage_service
      @gas_usage_service ||= usage_service(:gas)
    end

    def electricity_usage_service
      @electricity_usage_service ||= usage_service(:electricity)
    end

    def usage_service(fuel_type)
      Schools::Advice::LongTermUsageService.new(@school, aggregate_school, fuel_type)
    end

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

    def set_counts
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
