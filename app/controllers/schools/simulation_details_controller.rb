require 'dashboard'

class Schools::SimulationDetailsController < Schools::SimulationsController
  include SchoolAggregation

  before_action :authorise_school
  before_action :set_simulation, only: :show

  def show
    @simulation_configuration = @simulation.configuration
    local_school = aggregate_school(@school)

    simulator = ElectricitySimulator.new(local_school)
    simulator.simulate(@simulation_configuration)
    chart_manager = ChartManager.new(local_school, false)

    @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:simulator_detail][:charts]
    @number_of_charts = @charts.size

    respond_to do |format|
      format.html do
        @charts_for_page = sort_out_charts_for_page(@charts)
        render :show
      end
      format.json do
        # Load specific chart type, else default above
        if params[:chart_type]
          chart_type = params[:chart_type]
          chart_type = chart_type.to_sym if chart_type.instance_of? String
          @charts = [chart_type]
        end

        # Allows for single run with all charts, or parallel
        @output = @charts.map do |this_chart_type|
          { chart_type: this_chart_type, data: chart_manager.run_chart_group(this_chart_type) }
        end

        @output = sort_out_group_charts(@output)
        @number_of_charts = @output.size
        render 'schools/analysis/chart_data'
      end
    end
  end

private

  # Only used by details at the moment
  def sort_out_charts_for_page(charts_config)
    charts_for_page = []
    charts_config.each do |chart|
      if chart.is_a?(Hash) && chart.key?(:chart_group)
        chart[:chart_group][:charts].each_with_index do |c, index|
          charts_for_page << { type: c, layout: :side_by_side, index: index }
        end
      else
        charts_for_page << { type: chart, layout: :normal }
      end
    end
    charts_for_page
  end
end
