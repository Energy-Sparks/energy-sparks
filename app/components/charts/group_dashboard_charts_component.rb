module Charts
  class GroupDashboardChartsComponent < ApplicationComponent
    attr_reader :school_group, :reports

    renders_one :title
    renders_one :intro

    def initialize(school_group:,
                   comparisons: [:annual_energy_use, :annual_energy_costs_per_pupil, :annual_energy_costs_per_floor_area],
                   **_kwargs)
      super
      @school_group = school_group
      @reports = comparisons.map { |k| Comparison::Report.find_by_key(k) }
    end

    def render?
      reports&.any?
    end

    def chart_config_json(id)
      {
        chart_type: id,
        chart1_type: :bar,
        chart1_subtype: :stacked,
        no_zoom: true,
        jsonUrl: comparison_report_path(id),
        transformations: [],
        annotations: []
      }.to_json
    end

    def comparison_report_path(report)
      path = [:comparisons, report.key.to_sym]
      # If the key is plural then rails routing works slightly  differently, so exclude :index component
      path << :index if report.key.singularize == report.key
      begin
        polymorphic_path(path, params: { school_group_ids: [school_group.id] }, format: :json)
      rescue NoMethodError
        nil
      end
    end
  end
end
