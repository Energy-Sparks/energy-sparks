module Management
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation
    include DashboardEnergyCharts
    include DashboardAlerts
    include DashboardTimeline

    before_action :check_aggregated_school_in_cache

    def show
      authorize! :show_management_dash, @school
      @charts = setup_charts(@school.configuration)
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.management_dashboard, :management_dashboard_title)
      @observations = setup_timeline(@school.observations)
      @management_priorities = setup_priorities
    end


    private

    def setup_priorities
      @school.latest_management_priorities.sample(5).map do |priority|
        template_variables = priority.alert.template_variables.with_indifferent_access
        TemplateInterpolation.new(
          priority.content_version,
          with_objects: {
            find_out_more: priority.find_out_more,
            average_capital_cost: template_variables[:average_capital_cost],
            average_payback_years: template_variables[:average_payback_years],
            average_one_year_saving_gbp: template_variables[:average_one_year_saving_gbp],
            average_ten_year_saving_gbp: template_variables[:ten_year_saving_gbp_low] # TODO: replace when variable gets implemented
          },
          proxy: [:colour]
        ).interpolate(
          :management_priorities_title,
          with: priority.alert.template_variables
        )
      end
    end
  end
end
