module Charts
  # Display a comparison report chart for a specific group only.
  class GroupComparisonChartComponent < ApplicationComponent
    attr_reader :school_group, :report

    renders_one :title
    renders_one :subtitle
    renders_one :header
    renders_one :footer

    def initialize(school_group:, report:, **_kwargs)
      super
      @school_group = school_group
      @report = report
    end

    private

    def chart_config_json
      {
        chart_type: @report.key,
        chart1_type: :bar,
        chart1_subtype: :stacked,
        no_zoom: true,
        jsonUrl: comparison_report_path,
        transformations: [],
        annotations: []
      }.to_json
    end

    def comparison_report_path
      path = [:comparisons, @report.key.to_sym]
      # If the key is plural then rails routing works slightly  differently, so exclude :index component
      path << :index if @report.key.singularize == @report.key
      begin
        polymorphic_path(path, params: { school_group_ids: [@school_group.id] }, format: :json)
      rescue NoMethodError
        nil
      end
    end
  end
end
