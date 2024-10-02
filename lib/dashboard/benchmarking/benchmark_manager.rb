
module Benchmarking
  class BenchmarkManager
    include Logging
    class DatabaseRow < OpenStruct
      attr_reader :school_id

      def initialize(school_id, school_data)
        super(school_data)
        @school_id = school_id
        @change_refs = []
      end

      def zero(value)
        value.nil? ? 0.0 : value
      end

      def percent_change(base, new_val, to_nil_if_sum_zero = false)
        return nil if to_nil_if_sum_zero && sum_data(base) == 0.0
        return 0.0 if sum_data(base) == 0.0
        change = (sum_data(new_val) - sum_data(base)) / sum_data(base)
        (to_nil_if_sum_zero && change == 0.0) ? nil : change
      end

      def or_nil(arr)
        arr.compact.empty? ? nil : arr.compact[0]
      end

      # NB if you change this format, you need to change the decode
      #    function def remove_references(school_name) in benchmark_content_general.rb
      def referenced(name, changed, percent, tariff_changed = nil)
        @change_refs.push(1) if changed
        @change_refs.push(2) if percent ==  Float::INFINITY
        @change_refs.push(3) if percent == -Float::INFINITY
        @change_refs.push(6) if !tariff_changed.nil? && tariff_changed

        @change_refs.empty? ? name : "#{name} (* #{@change_refs.join(',')})"
      end

      def tariff_change_reference(name, changed)
        @change_refs.push(5) if changed
        @change_refs.empty? ? name : "#{name} (* #{@change_refs.join(',')})"
      end

      # helper function for config lamda, only sums
      # where corresponding components are non nil
      def paired_sum(data1, data2)
        data1.zip(data2).sum{ |pair| pair.any?{ |el| el.nil?} ? 0.0 : pair.sum }
      end

      def sum_data(data, to_nil_if_sum_zero = false)
        data = [data] unless data.is_a?(Array)
        data.map! { |value| zero(value) } # create array 1st to avoid statsample map/sum bug
        val = data.sum
        (to_nil_if_sum_zero && val == 0.0) ? nil : val
      end

      # specialist sum, only adds if 1st 2 vals i.e. electricity & gas present or same
      # between 2 years, so doesn't display sum for previous year if data incomplete
      def sum_if_complete(data_prev, data_curr)
        eg_prev = data_prev[0..1].map(&:nil?)
        eg_curr = data_curr[0..1].map(&:nil?)

        return nil if eg_prev != eg_curr

        sum_data(data_prev)
      end

      def area
        addp_area.nil? ? '?' : addp_area.split(' ')[0]
      end

      def partial(holiday_name, partial)
        partial ? holiday_name + '(partial)' : holiday_name
      end

      def school_name
        addp_name
      end
    end

    attr_reader :benchmark_database

    def initialize(benchmark_database)
      @benchmark_database = benchmark_database
    end

    def self.report_dates(today, report = :annual_gas_per_floor_area_chart)
      [today] # only today would be needed for the example
    end

    def run_benchmark_chart(today, report, school_ids, chart_columns_only = false, filter = nil, user_type = nil)
      config = self.class.chart_table_config(report)
      table = run_benchmark_table(today, report, school_ids, chart_columns_only, filter, :raw, user_type)
      create_chart(report, config, table, true, user_type)
    end

    # filter e.g. for area: ->{ addp_area.include?('Highlands') }
    def run_benchmark_table(today, report, school_ids, chart_columns_only = false, filter = nil, medium = :raw, user_type)
      create_and_store_school_map(report, today, school_ids, user_type)
      #@school_name_urn_map = school_map(today, school_ids, user_type) if benchmark_has_drilldown?(report)
      run_benchmark_table_private(today, report, school_ids, chart_columns_only, filter, medium, true, user_type, true)
    end

    def run_table_including_aggregate_columns(today, report, school_ids, chart_columns_only = false, filter = nil, medium = :raw, user_type)
      ignore_aggregate_columns = false
      hide_visible_columns = false
      run_benchmark_table_private(today, report, school_ids, chart_columns_only, filter, medium, ignore_aggregate_columns, user_type, hide_visible_columns)
    end

    def drilldown_class(report)
      self.class.chart_table_config(report).fetch(:drilldown, nil)
    end

    private

    def create_and_store_school_map(report, today, school_ids, user_type)
      if benchmark_has_drilldown?(report)
        @school_name_urn_map ||= school_map(today, school_ids, user_type)
      end
    end

    def benchmark_has_drilldown?(report)
      config = self.class.chart_table_config(report)
      config[:columns].any?{ |column_definition| column_definition.key?(:content_class) }
    end

    def run_benchmark_table_private(today, report, school_ids, chart_columns_only = false, filter = nil, medium = :raw, ignore_aggregate_columns, user_type, hide_visible_columns)
      results = []
      full_config = self.class.chart_table_config(report)

      config = hide_columns(full_config, user_type, ignore_aggregate_columns)
      school_ids = all_school_ids([today]) if school_ids.nil?
      last_year = today - 364
      school_ids.each do |school_id|
        school_data = @benchmark_database.fetch(today, {}).fetch(school_id)
        # @benchmark_database.@benchmark_database.fetch(last_year){{}}.fetch(school_id)
        # school_data_last_year = @benchmark_database.dig(last_year, school_id)
        # school_data.merge!(dated_attributes('_last_year', school_data_last_year)) unless school_data_last_year.nil?
        next if school_data.nil? || school_data.empty? # && school_data_last_year
        row  = DatabaseRow.new(school_id, school_data)
        next unless filter_row(row, filter)
        next if config.key?(:where) && !filter_row(row, config[:where])
        calculated_row = calculate_row(row, config, chart_columns_only, school_id)

        results.push(calculated_row) if row_has_useful_data(calculated_row, config, chart_columns_only)
      end

      sort_table!(results, config) if config.key?(:sort_by)

      format_table(config, results, medium, hide_visible_columns)
    end

    def school_map(asof_date, school_ids, user_type)
      schools = run_benchmark_table_private(asof_date, :school_information, school_ids, false, nil, :raw, true, user_type, false)
      schools.map do |school_data|
        [
          school_data[2],
          { name: school_data[0], urn: school_data[1]}
        ]
      end.to_h
    end

    def hide_columns(config, user_type, ignore_aggregate_columns)
      # clone to get new config, then filter (reject) for new column definitions
      new_config = config.clone

      new_config[:columns] = new_config[:columns].reject do |column|
        rating_column?(column) && !ContentBase.analytics_user?(user_type)
      end

      if ignore_aggregate_columns
        new_config[:columns] = new_config[:columns].reject do |column|
          column[:aggregate_column] == :dont_display_in_table_or_chart
        end
      end

      new_config
    end

    def sort_table!(results, config)
      if config[:sort_by].is_a?(Array)
        sort_table_by_column!(results, config)
      elsif config[:sort_by].is_a?(Method)
        results.sort! { |a, b| config[:sort_by].call(a[:data], b[:data]) }
      end
    end

    def sort_table_by_column!(results, config)
      results.sort! do |row1, row2|
        sort_level = 0 # multi-column sort
        compare = nil
        loop do
          reverse_it = false
          sort_col = config[:sort_by][sort_level]
          if sort_col.is_a?(Hash)
            reverse_it = true
            sort_col = sort_col.values[0]
          end
          sort_col_type = config[:columns][sort_col][:units]
          compare = sort_compare(row1, row2, sort_col, sort_col_type)
          compare *= -1 unless reverse_it
          sort_level += 1
          break if sort_level >= config[:sort_by].length || compare != 0
        end
        compare
      end
      results
    end

    def sort_compare(row1, row2, sort_col, sort_col_type)
      if sort_col_type == :timeofday
        time_of_day_compare(row1[:data][sort_col], row2[:data][sort_col])
      elsif sort_col_type == String
        row1[:data][sort_col] <=> row2[:data][sort_col]
      else
        nan_to_infinity(row1[:data][sort_col].to_f) <=> nan_to_infinity(row2[:data][sort_col].to_f)
      end
    end

    def nan_to_infinity(v)
      v.is_a?(Float) && v.nan? ? Float::INFINITY : v
    end

    def format_table(table_definition, rows, medium, hide_visible_columns)
      header, raw_rows = remove_hidden_columns(table_definition, rows, hide_visible_columns)
      school_ids = rows.map{ |d| d[:school_id] }

      case medium
      when :raw
        [header] + raw_rows
      when :text, :text_and_raw
        formatted_rows = format_rows(raw_rows, table_definition, medium, school_ids, hide_visible_columns)
        {
          column_groups: translate_column_groups_for(table_definition[:column_groups]),
          header: header,
          rows: formatted_rows
        }
      when :html
        formatted_rows = format_rows(raw_rows, table_definition, medium, school_ids, hide_visible_columns)
        HtmlTableFormatting.new(header, formatted_rows).html(column_groups: translate_column_groups_for(table_definition[:column_groups]))
      end
    end

    def translate_column_groups_for(column_groups)
      return unless column_groups
      translated_column_groups = []
      column_groups.each do |column_group|
         translated_column_groups << {
           name: column_group[:name].present? ? I18n.t("analytics.benchmarking.configuration.column_groups.#{column_group[:name]}"): '',
           span: column_group[:span]
         }
      end
      translated_column_groups
    end

    def format_rows(rows, table_definition, medium, school_ids, hide_visible_columns)
      column_definitions = table_definition[:columns]
      column_units    = visible_data(table_definition, column_definitions.map{ |column_definition| column_definition[:units] }, hide_visible_columns)
      column_sense    = visible_data(table_definition, column_definitions.map{ |column_definition| column_definition.dig(:sense) }, hide_visible_columns)
      content_classes = visible_data(table_definition, column_definitions.map{ |column_definition| column_definition.dig(:content_class) }, hide_visible_columns)
      formatted_rows = rows.each_with_index.map do |row, row_number|
        row.each_with_index.map do |value, index|
          sense = sense_column(column_sense[index])
          drilldown = content_classes[index]
          if column_units[index] == String
            format_cell_string(value, medium, sense, drilldown, school_ids[row_number])
          else
            format_cell(column_units[index], value, medium, sense)
          end
        end
      end
    end

    def visible_data(table_definition, data, hide_visible_columns)
      return data unless hide_visible_columns
      visible_columns = table_definition[:columns].map { |cd| cd[:hidden] != true }
      data.select.with_index { |_v, i| visible_columns[i] }
    end

    def remove_hidden_columns(table_definition, rows, hide_visible_columns)
      visible_columns = table_definition[:columns].map { |cd| cd[:hidden] != true }

      header    = table_definition[:columns].map do |column_definition|
        I18n.t("analytics.benchmarking.configuration.column_headings.#{column_definition[:name].downcase}") if column_definition[:name]
      end
      header    = visible_data(table_definition, header, hide_visible_columns)
      raw_rows  =  rows.map { |row| visible_data(table_definition, row[:data], hide_visible_columns) }
      [header, raw_rows]
    end

    def sense_column(sense)
      sense.nil? ? nil : { sense: sense }
    end

    def format_cell_string(value, medium, sense, drilldown, school_id)
      if medium == :text_and_raw
        data = {
          formatted: value,
          raw: value
        }
        data.merge!(sense) unless sense.nil?
        unless school_id.nil? || drilldown.nil?
          data[:urn] = @school_name_urn_map[school_id][:urn]
          data[:drilldown_content_class] = drilldown
        end
        data
      else
        value
      end
    end

    def content_class_urn_info(school_name, content_class)
      {
        school_name:    school_name,
        urn:            @school_name_urn_map[school_name],
        content_class:  content_class
      }
    end

    def format_cell(units, value, medium, sense)
      if medium == :text_and_raw
        data = {
          formatted: format_cell(units, value, :text, nil),
          raw: value
        }
        data.merge!(sense) unless sense.nil?
        data
      else
        FormatEnergyUnit.format(units, value, medium, false, true, :benchmark)
      end
    end

    # avoid doing in TimeOfDay class as reduces performance of default
    def time_of_day_compare(tod1, tod2)
      if [tod1, tod2].count(&:nil?) == 1
        tod1.nil? ? 1 : -1
      else
        tod1 <=> tod2
      end
    end

    def row_has_useful_data(calculated_row, config, chart_columns_only)
      min_non_nulls = 1 + (self.class.y2_axis_column?(config) ? 1 : 0)
      !calculated_row.nil? && !calculated_row[:data].nil? && (items_useful_data(calculated_row, config) > min_non_nulls)
    end

    def items_useful_data(row, config)
      row[:data].count{ |cell| !cell_nil?(cell, config) }
    end

    def cell_nil?(cell, config)
      cell.nil? || (config.key?(:treat_as_nil) && config[:treat_as_nil].include?(cell))
    end

    def create_chart(chart_name, config, table, include_y2, user_type)
      config = hide_columns(config, user_type, true)

      # need to extract 1st 2 'chart columns' from table data
      chart_columns_definitions = config[:columns].select {|column_definition| self.class.chart_column?(column_definition)}
      chart_column_numbers = config[:columns].each_with_index.map {|column_definition, index| self.class.chart_column?(column_definition) ? index : nil}
      chart_column_numbers.compact!

      graph_definition = {}
      graph_definition[:title]          = config[:name]
      graph_definition[:x_axis]         = remove_first_column(table.map { |row| row[chart_column_numbers[0]] })
      graph_definition[:x_axis_ranges]  = nil
      graph_definition[:x_data]         = create_chart_data(config, table, chart_column_numbers, chart_columns_definitions)
      graph_definition[:chart1_type]    = :bar
      graph_definition[:chart1_subtype] = :stacked
      graph_definition[:y_axis_label]   = y_axis_label(chart_columns_definitions)
      graph_definition[:config_name]    = chart_name.to_s

      min_x_value = calculate_min_x_value(graph_definition[:x_data], config)
      graph_definition[:x_min_value] = min_x_value unless min_x_value.nil?

      max_x_value = calculate_max_x_value(graph_definition[:x_data], config)
      graph_definition[:x_max_value] = max_x_value unless max_x_value.nil?

      unless Object.const_defined?('Rails')
        # clean up NaNs and Infinities so Excel doesn't blow up
        graph_definition[:x_data].transform_values! do |array|
          array.map! do |v|
            v.is_a?(Float) && !v.finite? ? nil : v
          end
        end
      end

      y2_data = create_y2_data(config, table, chart_column_numbers, chart_columns_definitions)

      unless y2_data.empty? || !include_y2
        graph_definition[:y2_data] = y2_data
        graph_definition[:y2_chart_type] = :line
      end

      graph_definition
    end

    def y_axis_type(chart_columns_definitions)
      first_chart_data_column = chart_columns_definitions[1] # [0] = school name
      first_chart_data_column[:units]
    end

    def y_axis_label(chart_columns_definitions)
      y_axis_label_name(y_axis_type(chart_columns_definitions))
    end

    def y_axis_label_name(unit)
      unit_names = {
        kwh: I18n.t('chart_configuration.y_axis_label_name.kwh'),
        kw: I18n.t('chart_configuration.y_axis_label_name.kw'),
        co2: I18n.t('chart_configuration.y_axis_label_name.co2'),
        £: I18n.t('chart_configuration.y_axis_label_name.£'),
        w: I18n.t('chart_configuration.y_axis_label_name.w'),
        £_0dp: I18n.t('chart_configuration.y_axis_label_name.£_0dp'),
        timeofday: I18n.t('chart_configuration.y_axis_label_name.timeofday'),
        percent: I18n.t('chart_configuration.y_axis_label_name.percent'),
        percent_0dp: I18n.t('chart_configuration.y_axis_label_name.percent_0dp'),
        relative_percent: I18n.t('chart_configuration.y_axis_label_name.relative_percent'),
        relative_percent_0dp: I18n.t('chart_configuration.y_axis_label_name.relative_percent_0dp'),
        days: I18n.t('chart_configuration.y_axis_label_name.days'),
        r2: I18n.t('chart_configuration.y_axis_label_name.r2')
      }
      return unit_names[unit] if unit_names.key?(unit)
      logger.info "Unexpected untranslated unit type for benchmark chart #{unit}"
      puts "Unexpected untranslated unit type for benchmark chart #{unit}"
      unit.to_s.humanize.gsub(' 0dp', '')
    end

    def remove_first_column(row)
      # return the data, the 1st entry is the column heading/series/label
      row.drop(1)
    end

    def create_chart_data(config, table, chart_column_numbers, chart_columns_definitions)
      data, _y2_data = select_chart_data(config, table, chart_column_numbers, chart_columns_definitions, :y1)
      data
    end

    def calculate_min_x_value(x_data, config)
      min_x_value = config[:min_x_value]

      return nil if min_x_value.nil?

      ap x_data
      min_chart_value = x_data.values.map { |vals| strip_nan(vals).compact.min }.compact.min

      # only set chart range if any value below minimum specified
      min_chart_value < min_x_value ? min_x_value : nil
    end

    def calculate_max_x_value(x_data, config)
      max_x_value = config[:max_x_value]
      return nil if max_x_value.nil?

      max_chart_value = x_data.values.map { |vals| strip_nan(vals).compact.max }.compact.max
      return nil if max_chart_value.nil?

      # only set chart range if any value below maximum specified
      max_chart_value > max_x_value ? max_x_value : nil
    end

    def strip_nan(arr)
      arr.reject { |v| v.nil? || !v.is_a?(Float) || v.nan? }
    end

    def create_y2_data(config, table, chart_column_numbers, chart_columns_definitions)
      _data, y2_data = select_chart_data(config, table, chart_column_numbers, chart_columns_definitions, :y2)
      y2_data
    end

    def select_chart_data(config, table, chart_column_numbers, chart_columns_definitions, axis)
      chart_data = {}
      y2_data = {}
      chart_column_numbers.each_with_index do |chart_column_number, index|
        next if index == 0 # skip entry as its the school name
        data = remove_first_column(table.map{ |row| row[chart_column_number] })
        series_name = I18n.t("analytics.benchmarking.configuration.column_headings.#{chart_columns_definitions[index][:name].downcase}")
        if axis == :y1 && self.class.y1_axis_column?(chart_columns_definitions[index])
          chart_data[series_name] = data
          percent_type = %i[percent relative_percent percent_0dp relative_percent_0dp].include?(chart_columns_definitions[1][:units])
          chart_data[series_name].map! { |val| val.nil? ? nil : val * 100.0 } if percent_type
          #when benchmark data is stored as json, TimeOfDay is stored as Strings.
          #for the chart data we want the TimeOfDay objects so they can be converted to relative time
          #so create objects if needed
          if chart_columns_definitions[1][:units] == :timeofday
            chart_data[series_name].map! { |val| val.is_a?(String) ? TimeOfDay.parse(val) : val }
          end
        elsif axis == :y2 && self.class.y2_axis_column?(chart_columns_definitions[index])
          y2_data[series_name] = data
        end
      end

      [chart_data, y2_data]
    end

    def dated_attributes(suffix, school_data)
      school_data.transform_keys { |key| key.to_s + suffix }
    end

    def filter_row(row, filter)
      return true if filter.nil?
      row.instance_exec(&filter)
    end

    def calculate_row(row, report, chart_columns_only, school_id)
      row_data = report[:columns].map do |column_specification|
        next if chart_columns_only && !self.class.chart_column?(column_specification)
        calculate_value(row, column_specification, school_id)
      end
      { data: row_data, school_id: school_id }
    end

    def rating_column?(column_specification)
      column_specification[:name] == :rating
    end

    def calculate_value(row, column_specification, school_id_debug)
      begin
        case column_specification[:data]
        when String
          row.send(column_specification[:data])
        when Proc
          row_data = row.instance_exec(&column_specification[:data])
          if row_data.is_a? String
            row_data.blank? ? '' : I18n.t("analytics.benchmarking.chart_table_config.data.metering.#{row_data}", default: row_data)
          else
            row_data
          end
        else
          nil
        end
      rescue StandardError => e
        name = row.instance_exec(& ->{ school_name })
        logger.info format_rescue_message(e, school_id_debug, column_specification, name)
        return nil
      end
    end

    def format_rescue_message(e, school_id_debug, column_specification, name)
      line_number = column_specification.to_s.split(':')[4][0..3]
      "#{e.message}: school id #{school_id_debug} line #{line_number} #{name[0..10]}"
    end

    def all_school_ids(selected_dates)
      list_of_school_ids = {}
      selected_dates.each do |date|
        school_ids = @benchmark_database[date].keys
        school_ids.each do |school_id|
          list_of_school_ids[school_id] = true
        end
      end
      list_of_school_ids.keys
    end
  end
end
