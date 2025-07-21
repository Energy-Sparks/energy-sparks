module Schools
  class AdviceController < ApplicationController
    include NonPublicSchools
    include DashboardAlerts
    include SchoolInactive
    include SchoolAggregation

    load_resource :school
    skip_before_action :authenticate_user!
    before_action { redirect_unless_permitted :show } # redirect to login if user can't view the school
    # Redirect guest / not logged in users to the pupil dashboard if not
    # data enabled to offer a better initial user experience
    before_action :redirect_to_pupil_dash_if_not_data_enabled, only: [:show]

    before_action :school_inactive
    before_action :load_advice_pages
    before_action :set_tab_name
    before_action :set_breadcrumbs
    before_action :check_aggregated_school_in_cache, only: [:show]

    def show
      @overview_data = Schools::ManagementTableService.new(@school).management_data
      @aggregate_school_service = aggregate_school_service
      render :show, layout: 'dashboards'
    end

    def priorities
      @management_priorities = Schools::Priorities.by_average_one_year_saving(latest_management_priorities)
      render :priorities, layout: 'dashboards'
    end

    def alerts
      @dashboard_alerts = setup_alerts(latest_dashboard_alerts, :management_dashboard_title, limit: nil)
      render :alerts, layout: 'dashboards'
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

    def not_signed_in?
      !user_signed_in? || current_user.guest?
    end

    def redirect_to_pupil_dash_if_not_data_enabled
      redirect_to pupils_school_path(@school) if not_signed_in? && !@school.data_enabled
    end

    def latest_dashboard_alerts
      @latest_dashboard_alerts ||= @school.latest_dashboard_alerts.management_dashboard
    end

    def latest_management_priorities
      @latest_management_priorities ||= @school.latest_management_priorities
    end
  end
end
