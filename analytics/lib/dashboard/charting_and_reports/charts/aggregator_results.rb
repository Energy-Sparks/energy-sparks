# warning this is an OpenStruct so internal local variables
# can potentially be accidently instantiated as class values
class AggregatorResults < OpenStruct
  def valid?
    !bucketed_data.nil? && !bucketed_data.empty?
  end

  def unpack
    basic_results.values
  end

  def basic_results
    list = %i[bucketed_data bucketed_data_count x_axis x_axis_bucket_date_ranges y2_axis]
    list.map { |k| [k, self[k]] }.to_h
  end

  def bucketless_result_copy
    hash = self.to_h.reject { |k, _v| %i[bucketed_data, bucketed_data_count].include?(k) }
    AggregatorResults.new(hash)
  end

  def set_y_axis_label(label)
    self.y_axis_label = label
  end

  def unpack2
    all_results.values
  end

  def all_results
    list = %i[bucketed_data bucketed_data_count x_axis x_axis_bucket_date_ranges y2_axis series_manager series_names xbucketor data_labels x_axis_label y_axis_label]
    list.map { |k| [k, self[k]] }.to_h
  end

  def time_description
    self.xbucketor.compact_date_range_description
  end

  def reverse_x_axis
    self.x_axis = self.x_axis.reverse
    self.x_axis_bucket_date_ranges = self.x_axis_bucket_date_ranges.reverse

    self.bucketed_data.each_key do |series_name|
      self.bucketed_data[series_name] = self.bucketed_data[series_name].reverse
      self.bucketed_data_count[series_name] = self.bucketed_data_count[series_name].reverse
    end

    unless self.y2_axis.nil?
      self.y2_axis.each_key do |series_name|
        self.y2_axis[series_name] = self.y2_axis[series_name].reverse
      end
    end
  end

  # performs scaling to 200, 1000 pupils or primary/secondary default sized floor areas
  # TODO(PH, 20Mar2022) - needs converting following refactor, not used by main stream code
  # at the moment, but part of the school comparison, averaging infrastructure which isn't used
  # by the front end at the moment
  def scale_x_data(chart_config, school)
    # exclude y2_axis values e.g. temperature, degree days
    x_data_keys = self.bucketed_data.select { |series_name, _data| !Series::ManagerBase.y2_series_types.values.include?(series_name) }
    scale_factor = YAxisScaling.new.scaling_factor(chart_config.yaxis_scaling, school)
    self.x_data_keys.each_key do |data_series_name|
      self.bucketed_data[data_series_name].each_with_index do |value, index|
        self.bucketed_data[data_series_name][index] = value * scale_factor
      end
    end
  end
end
