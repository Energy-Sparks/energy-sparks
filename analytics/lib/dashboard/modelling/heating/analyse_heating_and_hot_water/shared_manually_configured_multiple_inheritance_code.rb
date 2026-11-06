require_relative 'heating_model/regression_model_temperature_manually_configured'

module AnalyseHeatingAndHotWater
  module SharedManuallyConfiguredMultipleInheritanceCode
    attr_reader :reason

    def initialize(heat_meter, model_overrides)
      super

      @reason = model_overrides.reason
      model_overrides.override_regression_model[:regression_models].each do |key, model|
        m = HeatingModel::RegressionModelTemperatureManuallyConfigured.new(
          key,
          key.to_s,
          model[:a].to_f,
          model[:b].to_f,
          model[:base_temperature].to_f
        )
        @models[key] = m
      end
    end

    def name
      'Overridden'
    end

    def enough_samples_for_good_fit
      true
    end

    # just assign sample data, don't calculate model as manually set
    def calculate_regression_model(period, _allow_more_than_1_year, _non_heating_model)
      bm = Benchmark.realtime do
        x_data, y_data = assign_models(period)
        x_data.each do |model_type, samples|
          next unless @models.key?(model_type)

          @models[model_type].samples = samples.length
          @models[model_type].x = samples
          @models[model_type].y = y_data[model_type]
        end
        @standard_deviation, @standard_deviation_percent = standard_deviation_from_model(period.start_date,
                                                                                         period.end_date)
      end
      @model_calculation_time = bm
    end
  end
end
