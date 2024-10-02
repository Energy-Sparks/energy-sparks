module Benchmarking
  class BenchmarkContentBase
    include Logging
    attr_reader :benchmark_manager, :asof_date, :page_name, :chart_table_config
    def initialize(benchmark_database, asof_date, page_name, chart_table_config, online=false)
      @benchmark_manager = BenchmarkManager.new(benchmark_database)
      @asof_date = asof_date
      @page_name = page_name
      @chart_table_config = chart_table_config
      @online = online
    end

    def front_end_content(school_ids: nil, filter: nil)
      content(school_ids, filter).select{ |content_config| %i[html chart_name chart table title].include?(content_config[:type]) }
    end

    def content(school_ids: nil, filter: nil, user_type: nil)
      charts = nil
      tables = nil
      caveats = nil

      chart       = run_chart(school_ids, filter, user_type)                if charts?
      composite   = run_table(school_ids, filter, :text_and_raw, user_type) if tables?

      if (tables? || charts?) && composite[:rows].empty?
        tables = { type: :html, content: '<h3>' + I18n.t('analytics.benchmarking.configuration.no_schools_to_report_for_filter') + '</h3>' }
      else
        charts = [
          { type: :html,                  content: chart_introduction_text },
          { type: :chart_name,            content: chart_name },
          { type: :chart,                 content: chart },
          { type: :html,                  content: chart_interpretation_text },
        ] if charts? && !chart_empty?(chart)

        if tables?
          tables = [{ type: :html, content: table_introduction_text}]

          #only generate these additional versions of the table if we're not running
          #as part of the application, as they're unused and result in extra memory usage
          if !online?
            table_html  = run_table(school_ids, filter, :html, user_type)
            tables.push({ type: :table_html,            content: table_html })

            table_text  = run_table(school_ids, filter, :text, user_type)
            tables.push({type: :table_text,            content: table_text })
          end

          footnote_text = footnote(school_ids, filter, user_type)

          tables.push({ type: :table_composite, content: composite })
          tables.push({ type: :html,            content: footnote_text })
          tables.push({ type: :html,            content: table_interpretation_text })
          tables.push({ type: :html,            content: tariff_changed_explanation(school_ids, filter, user_type) })
          tables.push({ type: :html,            content: column_heading_explanation })
        end

        caveats = [{ type: :html, content: caveat_text}]
      end

      [preamble_content, charts, tables, caveats, drilldown(school_ids, user_type)].compact.flatten
    end

    protected def preamble_content
      [
        { type: :analytics_html,        content: '<br>' },
        # { type: :html,                  content: content_title },
        { type: :title,                 content: I18n.t("analytics.benchmarking.chart_table_config.#{page_name}", default: chart_table_config[:name])},
        { type: :html,                  content: introduction_text },
      ]
    end

    private def online?
      @online
    end

    private def drilldown(school_ids, user_type)
      drilldown_info = benchmark_manager.drilldown_class(@page_name)
      return nil if drilldown_info.nil?
      {
        type:     :drilldown,
        content:  {
                    drilldown:  drilldown_info,
                    school_map: school_map(school_ids, user_type)
                  }
      }
    end

    private def school_map(school_ids, user_type)
      schools = benchmark_manager.run_benchmark_table(asof_date, :school_information, school_ids, false, nil, :raw, user_type)
      schools.map { |school_data| {name: school_data[0], urn: school_data[1]} }
    end

    protected def content_title
      title = I18n.t("analytics.benchmarking.chart_table_config.#{page_name}", default: "<h1>#{chart_table_config[:name]}</h1>")
      text = "<h1>#{title}</h1>"

      ERB.new(text).result(binding)
    end

    protected def introduction_text
      '<h3>Introduction here</h3>'
    end

    protected def chart_introduction_text
      '<h3>Chart Introduction</h3>'
    end

    protected def chart_interpretation_text
      '<h3>Chart interpretation</h3>'
    end

    protected def table_introduction_text
      '<h3>Table Introduction</h3>'
    end

    protected def table_interpretation_text
      '<h3>Table interpretation</h3>'
    end

    protected def caveat_text
      '<h3>Caveat</h3>'
    end

    def charts?
      chart_table_config[:type].include?(:chart)
    end

    def tables?
      chart_table_config[:type].include?(:table)
    end

    def chart_name
      page_name
    end

    def run_chart(school_ids, filter, user_type = nil)
      benchmark_manager.run_benchmark_chart(asof_date, page_name, school_ids, nil, filter, user_type)
    end

    def run_table(school_ids, filter, medium, user_type = nil)
      benchmark_manager.run_benchmark_table(asof_date, page_name, school_ids, nil, filter, medium, user_type)
    end

    def footnote(_school_ids, _filter, _user_type)
      ''
    end

    def chart_empty?(chart_results)
      chart_results.nil? || !chart_results[:x_data].values.any?{ |data| !data.all?(&:nil?) }
    end

    def extract_useful_aggregate_table_data_deprecated(table_with_header, column_ids)
      table_with_header.drop(1).map do |row| # skip header row|
        table_extract_aggregate_row_data(row, column_ids)
      end.compact
    end

    def table_extract_aggregate_row_data(row, column_ids)
      column_ids.map do |column_id|
        col_index = table_column_index(column_id)
        col_index.nil? ? nil : row[col_index]
      end.compact
    end

    def table_column_index(column_id)
      @chart_table_config[:columns].index { |v| v[:column_id] == column_id }
    end

    def raw_data(school_ids, filter, user_type)
      table_data(school_ids, filter, user_type).drop(1) # drop header
    end

    def column_headings(school_ids, filter, user_type)
      table_data(school_ids, filter, user_type)[0]
    end

    def table_data(school_ids, filter, user_type)
      table_data ||= {}
      key = [school_ids, filter, user_type]
      table_data[key] ||= benchmark_manager.run_table_including_aggregate_columns(asof_date, page_name, school_ids, nil, filter, :raw, user_type)
    end

    def column_heading_explanation
      return '' unless @chart_table_config[:column_heading_explanation]

      I18n.t("analytics.benchmarking.configuration.column_heading_explanation.#{@chart_table_config[:column_heading_explanation]}", default: '')
    end

    def includes_tariff_changed_column?(school_ids, filter, user_type)
      cols = column_headings(school_ids, filter, user_type)
      cols.any?{ |col_name| col_name == tariff_changed_column_name }
    end

    def tariff_has_changed?(school_ids, filter, user_type)
      col_index = column_headings(school_ids, filter, user_type).index(tariff_changed_column_name)
      return false if col_index.nil?

      data = raw_data(school_ids, filter, user_type)
      return false if data.nil? || data.empty?

      tariff_changes = data.map { |row| row[col_index] }

      tariff_changes.any?
    end

    def tariff_changed_column_name
      I18n.t("analytics.benchmarking.configuration.column_headings.#{:tariff_changed}")
    end

    def tariff_changed_explanation(school_ids, filter, user_type)
      if includes_tariff_changed_column?(school_ids, filter, user_type) && tariff_has_changed?(school_ids, filter, user_type)
        I18n.t('analytics.benchmarking.configuration.the_tariff_has_changed_during_the_last_year_html')
      else
        ''
      end
    end
  end
end
