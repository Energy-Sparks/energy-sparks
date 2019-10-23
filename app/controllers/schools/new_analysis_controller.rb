module Schools
  class NewAnalysisController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation

    before_action :check_aggregated_school_in_cache, only: :show

    def index
      @heating_pages = process_templates(@school.latest_analysis_pages.heating)
    end

    def show
      @page = @school.analysis_pages.find(params[:id])
      framework_adapter = Alerts::FrameworkAdapter.new(@page.alert.alert_type, @school, @page.alert.run_on, aggregate_school)
      @content = framework_adapter.content.select {|content| [:html, :chart_name].include?(content[:type]) }
    end


  private

    def process_templates(pages)
      pages.map do |page|
        TemplateInterpolation.new(
          page.content_version,
          with_objects: { rating: page.alert.rating, id: page.id }
        ).interpolate(
          :analysis_title, :analysis_subtitle,
          with: page.alert.template_variables
        )
      end
    end
  end
end
