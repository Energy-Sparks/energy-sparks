# frozen_string_literal: true

# Some shared objects for testing services, charts, etc.
#
# The full aggregation process isn't run, the objects are initialised and linked as needed
RSpec.shared_context 'with an aggregated meter with tariffs and school times', shared_context: :metadata do
  let(:fuel_type) { :electricity }

  # AMR data for the school
  # For testing the basic calculations we just use flat usage, carbon intensity
  # profile and flat tariff rates
  let(:usage_per_hh)      { 10.0 }
  let(:carbon_intensity)  { 0.2 }
  let(:flat_rate)         { 0.10 }

  let(:daily_usage)       { 48.0 * usage_per_hh }

  let(:amr_start_date)  { Date.new(2023, 12, 1) }
  let(:amr_end_date)    { Date.new(2023, 12, 31) }

  let(:amr_data) do
    build(:amr_data, :with_date_range, :with_grid_carbon_intensity,
          grid_carbon_intensity: grid_carbon_intensity,
          start_date: amr_start_date,
          end_date: amr_end_date,
          kwh_data_x48: Array.new(48) { usage_per_hh })
  end

  # Carbon intensity used to calculate co2 emissions
  let(:grid_carbon_intensity) do
    build(:grid_carbon_intensity, :with_days,
          start_date: amr_start_date,
          end_date: amr_end_date,
          kwh_data_x48: Array.new(48) { carbon_intensity })
  end

  let(:aggregate_meter) do
    build(:meter, :with_flat_rate_tariffs, type: fuel_type, amr_data: amr_data,
                                           tariff_start_date: amr_start_date,
                                           tariff_end_date: amr_end_date,
                                           rates: create_flat_rate(rate: flat_rate, standing_charge: 1.0),
                                           meter_collection:)
  end

  let(:community_use_times) { {} }

  # Open Monday-Friday, 7am-3pm, 8 hours of usage
  # Total kwh usage when open = 8 * 2 * usage_per_hh
  let(:school_times) do
    %i[monday tuesday wednesday thursday friday].map do |day|
      {
        day: day,
        usage_type: :school_day,
        opening_time: TimeOfDay.new(7, 0),
        closing_time: TimeOfDay.new(15, 0),
        calendar_period: :term_times
      }
    end
  end

  # Xmas holiday from 2023-12-16 to 2024-1-1, which is 11 weekdays during
  # the default period defined by amr_start_date and amr_end_date
  let(:holidays) { build(:holidays, :with_calendar_year, year: 2023) }

  let(:open_close_times) do
    build(
      :open_close_times,
      :from_frontend_times,
      school_times: school_times,
      holidays: holidays,
      community_times: community_use_times
    )
  end

  # TODO: add holidays, temperatures, solar
  let(:meter_collection) do
    build(:meter_collection, school: build(:analytics_school, school_times:, community_use_times:), holidays:)
  end

  # Configure objects as if we've run the aggregation process
  before do
    meter_collection.set_aggregate_meter(fuel_type, aggregate_meter)
    aggregate_meter.amr_data.open_close_breakdown = CommunityUseBreakdown.new(aggregate_meter, open_close_times)
    aggregate_meter.set_tariffs
  end
end
