module Schools
  module Advice
    class AdviceBaseController < ApplicationController
      include NonPublicSchools
      include AdvicePageHelper
      include SchoolAggregation
      include DashboardAlerts
      include SchoolInactive

      load_resource :school
      skip_before_action :authenticate_user!
      before_action { redirect_unless_permitted :show } # redirect to login if user can't view the school
      before_action :school_inactive
      before_action :load_advice_pages
      before_action :load_advice_page, only: [:insights, :analysis, :learn_more]
      before_action :check_authorisation, only: [:insights, :analysis, :learn_more]
      before_action :set_tab_name, only: [:insights, :analysis, :learn_more]
      before_action :load_recommendations, only: [:insights]
      before_action :set_page_title, only: [:insights, :analysis, :learn_more]
      before_action :check_has_fuel_type, only: [:insights, :analysis]
      before_action :check_aggregated_school_in_cache, only: [:insights, :analysis]
      before_action :set_analysis_dates, only: %i[insights analysis]
      before_action :check_can_run_analysis, only: [:insights, :analysis]
      before_action :set_data_warning, only: [:insights, :analysis]
      before_action :set_page_subtitle, only: [:insights, :analysis]
      before_action :set_breadcrumbs, only: [:insights, :analysis, :learn_more]
      before_action :set_insights_next_steps, only: [:insights]

      rescue_from StandardError do |exception|
        Rollbar.error(exception, advice_page: advice_page_key, school: @school.name, school_id: @school.id, tab: @tab)
        raise if !Rails.env.production? || @advice_page.nil?
        locale = LocaleFinder.new(params, request).locale
        I18n.with_locale(locale) do
          render 'error', status: :internal_server_error
        end
      end

      # Generic action used to respond to HEAD requests
      # See routes.rb for routing
      def handle_head
        head(:ok)
      end

      def show
        redirect_to url_for([:insights, @school, :advice, advice_page_key])
      end

      def learn_more
        @learn_more = @advice_page.learn_more
      end

      private

      def load_advice_pages
        @advice_pages = AdvicePage.all
      end

      def load_dashboard_alerts
        @dashboard_alerts = setup_alerts(latest_dashboard_alerts, :management_dashboard_title, limit: nil)
      end

      def latest_dashboard_alerts
        @latest_dashboard_alerts ||= @school.latest_dashboard_alerts.management_dashboard
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = if_exists('insights.next_steps')
      end

      def set_page_title
        @advice_page_title = t("advice_pages.#{@advice_page.key}.page_title")
      end

      def set_page_subtitle
        @advice_page_subtitle = if_exists("#{action_name}.title")
      end

      def set_breadcrumbs
        @breadcrumbs = [
          { name: t('advice_pages.breadcrumbs.root'), href: school_advice_path(@school) },
          { name: @advice_page_title, href: advice_page_path(@school, @advice_page) },
        ]
      end

      def if_exists(key)
        full_key = "advice_pages.#{@advice_page.key}.#{key}"
        if I18n.exists?(full_key, I18n.locale)
          t(full_key)
        end
      end

      def set_data_warning
        @data_warning = !@analysis_dates.recent_data
      end

      def set_tab_name
        @tab = action_name.to_sym
      end

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(advice_page_key)
      end

      def check_authorisation
        if @advice_page && @advice_page.restricted && cannot?(:read_restricted_advice, @school)
          redirect_to school_advice_path(@school), notice: 'Only an admin or staff user for this school can access this content'
        end
      end

      def check_has_fuel_type
        render('no_fuel_type', status: :bad_request) and return unless school_has_fuel_type?
        true
      end

      # Checks that the analysis can be run.
      # Enforces check that school has the necessary fuel type
      # and provides hook for controllers to plug in custom checks
      def check_can_run_analysis
        @analysable = create_analysable
        if @analysable.present? && !@analysable.enough_data?
          render 'not_enough_data'
        end
      end

      def school_has_fuel_type?
        @advice_page.school_has_fuel_type?(@school)
      end

      def advice_page_fuel_type
        @advice_page.fuel_type&.to_sym
      end

      # Should return an object that conforms to interface described
      # by the AnalysableMixin. Will be used to determine whether
      # there's enough data and, optionally, identify when we think there
      # will be enough data.
      def create_analysable
        nil
      end

      def load_recommendations
        activity_type_filter = ActivityTypeFilter.new(
          school: @school,
          scope: @advice_page.ordered_activity_types,
          query: { exclude_if_done_this_year: true }
        )
        @activity_types = activity_type_filter.activity_types.limit(4)

        intervention_type_filter = InterventionTypeFilter.new(
          school: @school,
          scope: @advice_page.ordered_intervention_types,
          query: { exclude_if_done_this_year: true }
        )
        @intervention_types = intervention_type_filter.intervention_types.limit(4)
      end

      def set_analysis_dates
        @analysis_dates = Schools::AnalysisDates.new(@school, advice_page_fuel_type)
      end
    end
  end
end
