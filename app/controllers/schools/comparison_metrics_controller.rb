module Schools
  class ComparisonMetricsController < ApplicationController
    load_and_authorize_resource :school

    def show
      authorize! :view_comparison_metrics, @school
      @run = BenchmarkResultSchoolGenerationRun.find(params[:id])
      @metrics = @run.metrics.includes(:metric_type).order(:alert_type_id, 'comparison_metric_types.fuel_type')
    end
  end
end
