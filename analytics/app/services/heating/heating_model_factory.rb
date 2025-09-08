# frozen_string_literal: true

module Heating
  class HeatingModelFactory
    def initialize(aggregate_meter, asof_date)
      @aggregate_meter = aggregate_meter
      @asof_date = asof_date
    end

    def create_model
      @aggregate_meter.model_cache.create_and_fit_model(:best, one_year_period)
    end

    private

    def one_year_period
      SchoolDatePeriod.new(:service, 'Current Year', model_start_date, @asof_date)
    end

    def model_start_date
      [one_year_ago, @aggregate_meter.amr_data.start_date].max
    end

    def one_year_ago
      @asof_date - 364
    end
  end
end
