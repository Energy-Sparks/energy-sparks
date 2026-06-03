# frozen_string_literal: true

module Charts
  module Filters
    # Support for filtering out specific series after a calculation has been completed
    class SeriesFilter < Base
      def filter
        unless @chart_config.chart_has_filter?
          logger.debug { 'No filters set' }
          return
        end

        logger.debug { "Filtering start #{@results.bucketed_data.keys}" }
        logger.debug { "Filters are: #{@chart_config.filters}" }

        to_keep = []
        to_keep = submeter_filter(to_keep)
        to_keep = heating_filter(to_keep)
        to_keep = model_type_filter(to_keep)
        to_keep = simple_filters(to_keep)
        to_keep = y2_axes(to_keep)

        remove_list = @results.bucketed_data.keys - to_keep

        remove_list.each do |remove_series_name|
          @results.bucketed_data.delete(remove_series_name)
        end

        logger.debug { "Filtered End #{@results.bucketed_data.keys}" }
      end

      private

      # With a submeter series breakdown the series are named using the meter name
      #
      # This method filters out sub meters based on their type. If there's no filter we
      # just keep all the series, otherwise we only keep those series whose meter is of a specific
      # sub_meter type (e.g. mains_consume, export, self_consume, etc)
      def submeter_filter(to_keep)
        return to_keep unless @chart_config.series_breakdown == :submeter

        # this is the meter whose sub meters are being displayed
        parent_meter = @results.series_manager.meter

        to_keep += if @chart_config.submeter_filter?
                     @chart_config.submeter_filter.each do |sub_meter_type|
                       to_keep << parent_meter.sub_meters[sub_meter_type].name if parent_meter.sub_meters.key?(sub_meter_type)
                     end
                   else
                     @results.bucketed_data.keys
                   end
        to_keep
      end

      def heating_filter(to_keep)
        return to_keep unless @chart_config.heating_filter?

        filter = [Series::HeatingNonHeating::HEATINGDAY]
        to_keep += pattern_match_list_with_list(@results.bucketed_data.keys, filter)
        to_keep
      end

      def model_type_filter(to_keep)
        return to_keep unless @chart_config.model_type_filter?

        # for model filters, copy in any trendlines for those models to avoid filtering
        model_filter = [@chart_config.model_type_filters].flatten(1)
        trendline_filters = model_filter.map { |model_name| Series::ManagerBase.trendline_for_series_name(model_name) }
        trendline_filters_with_parameters = pattern_match_two_symbol_lists(trendline_filters, @results.bucketed_data.keys)
        to_keep += pattern_match_list_with_list(@results.bucketed_data.keys, model_filter + trendline_filters_with_parameters)

        to_keep
      end

      def simple_filters(to_keep)
        %i[fuel daytype heating_daytype meter].each do |filter_type|
          if @chart_config.has_filter?(filter_type)
            filtered_data = [@chart_config.filter_by_type(filter_type)].flatten
            to_keep += pattern_match_list_with_list(@results.bucketed_data.keys, filtered_data)
          end
        end
        to_keep
      end

      # This is not a filter. It ensures that any Y2 axes series names are retained in the results
      #
      # Some charts do not have a y2 axes, but include series that might also be used on a y2 axis
      # E.g. thermostatic_regression.
      #
      # So this is applied to all charts, not just those with a y2 axis.
      def y2_axes(to_keep)
        Series::ManagerBase.y2_series_types.each_value do |y2_series_name|
          base_name_length = y2_series_name.length
          to_keep += @results.bucketed_data.keys.select { |bucket_name| bucket_name[0...base_name_length] == y2_series_name }
        end
        to_keep
      end

      def pattern_match_list_with_list(list, pattern_list)
        filtered_list = []
        pattern_list.each do |pattern|
          pattern_matched_list = list.select { |i| i == pattern }
          filtered_list += pattern_matched_list unless pattern_matched_list.empty?
        end
        filtered_list
      end

      # e.g. [:trendline_model_xyz] with [:trendline_model_xyz_a45_b67_r282] => [:trendline_model_xyz_a45_b67_r282]
      # only check for 'included in' not proper regexp
      # gets around problem with modifying bucket symbols before filtering
      def pattern_match_two_symbol_lists(match_symbol_list, symbol_list)
        matched_pairs = match_symbol_list.product(symbol_list).select { |match, sym| sym.to_s.include?(match.to_s) }
        matched_pairs.map { |_match, symbol| symbol }
      end

    end
  end
end
