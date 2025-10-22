# frozen_string_literal: true

require 'rails_helper'

describe Usage::UsageBreakdownService, type: :service do
  subject(:service) do
    described_class.new(meter_collection: meter_collection, fuel_type: fuel_type)
  end

  let(:fuel_type) { :electricity }

  # AMR data for the school
  # For testing the basic calculations we just use flat usage, carbon intensity
  # profile and flat tariff rates
  let(:usage_per_hh)      { 10.0 }
  let(:carbon_intensity)  { 0.2 }
  let(:flat_rate)         { 0.10 }

  let(:amr_start_date)  { Date.new(2023, 12, 1) }
  let(:amr_end_date)    { Date.new(2023, 12, 31) }

  let(:amr_data) do
    build(:amr_data, :with_date_range, :with_grid_carbon_intensity, grid_carbon_intensity: grid_carbon_intensity, start_date: amr_start_date, end_date: amr_end_date, kwh_data_x48: Array.new(48) { usage_per_hh })
  end

  # Carbon intensity used to calculate co2 emissions
  let(:grid_carbon_intensity) { build(:grid_carbon_intensity, :with_days, start_date: amr_start_date, end_date: amr_end_date, kwh_data_x48: Array.new(48) { carbon_intensity }) }

  let(:aggregate_meter) do
    build(:meter, :with_flat_rate_tariffs, type: fuel_type, amr_data: amr_data, tariff_start_date: amr_start_date, tariff_end_date: amr_end_date, rates: create_flat_rate(rate: flat_rate, standing_charge: 1.0))
  end

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

  # Xmas holiday from 2023-12-16 to 2024-1-1, which is 10 weekdays during
  # the default period defined by amr_start_date and amr_end_date
  let(:open_close_times) do
    build(
      :open_close_times,
      :from_frontend_times,
      school_times: school_times,
      holidays: build(:holidays, :with_calendar_year, year: 2023)
    )
  end

  let(:meter_collection) { build(:meter_collection) }

  # Configure objects as if we've run the aggregation process
  before do
    meter_collection.set_aggregate_meter(fuel_type, aggregate_meter)
    aggregate_meter.amr_data.open_close_breakdown = CommunityUseBreakdown.new(aggregate_meter, open_close_times)
    aggregate_meter.set_tariffs
  end

  describe '#enough_data?' do
    context 'with enough data' do
      it 'returns true' do
        expect(service.enough_data?).to be true
      end
    end

    context 'with less than a week of data' do
      let(:amr_start_date) { Date.new(2023, 12, 30) }

      it 'returns false' do
        expect(service.enough_data?).to be false
      end
    end
  end

  describe '#data_available_from' do
    context 'with enough data' do
      it 'returns nil' do
        expect(service.data_available_from).to be(nil)
      end
    end

    context 'with limited data' do
      let(:amr_start_date) { Date.new(2023, 12, 30) }

      it 'returns date when there is one years data' do
        expect(service.data_available_from).to eq(amr_start_date + 6)
      end
    end
  end

  describe '#out_of_hours_kwh' do
    subject(:usage) { service.out_of_hours_kwh }

    let(:days) { (amr_start_date..amr_end_date).count }
    let(:expected_total) { days * 48 * usage_per_hh }

    context 'with a month of usage' do
      # Usage when closed during the week
      let(:weekday_usage) { 11 * (48 - 16) * usage_per_hh }
      # 10 weekend days in December 2023. 4 days are "weekend", 6 days are "holiday"
      let(:weekend_usage) { 4 * 48 * usage_per_hh }
      # 10 week days are holidays plus 6 weekend days which are categorised
      # as holidays
      let(:holiday_usage) { 16 * 48 * usage_per_hh }
      let(:expected_out_of_hours) { weekend_usage + weekday_usage + holiday_usage }

      it 'returns the expected totals' do
        expect(usage[:total]).to eq(expected_total)
        expect(usage[:out_of_hours]).to eq(expected_out_of_hours)
      end

      context 'when a community use period has been defined' do
        # One hour each weekday
        let(:community_use_times) do
          %i[monday tuesday wednesday thursday friday].map do |day|
            {
              day: day,
              usage_type: :community_use,
              opening_time: TimeOfDay.new(15, 0),
              closing_time: TimeOfDay.new(16, 0),
              calendar_period: :term_times
            }
          end
        end

        let(:open_close_times) do
          build(
            :open_close_times,
            :from_frontend_times,
            school_times: school_times,
            holidays: build(:holidays, :with_calendar_year, year: 2023),
            community_times: community_use_times
          )
        end

        it 'returns the expected totals' do
          expect(usage[:total]).to eq(expected_total)
          expect(usage[:out_of_hours]).to eq(expected_out_of_hours)
        end
      end
    end

    context 'with a single school week of usage' do
      # Friday 1st to Friday 8th, 6 week days, 2 weekend days
      let(:amr_end_date)    { Date.new(2023, 12, 8) }

      # Usage when closed during the week
      let(:weekday_usage) { 6 * (48 - 16) * usage_per_hh }
      let(:weekend_usage) { 2 * 48 * usage_per_hh }
      # Usage during holidays, all usage out of hours
      let(:holiday_usage) { 0.0 }

      let(:expected_out_of_hours) { weekend_usage + weekday_usage + holiday_usage }

      it 'returns the expected totals' do
        usage = service.out_of_hours_kwh
        expect(usage[:total]).to eq(expected_total)
        expect(usage[:out_of_hours]).to eq(expected_out_of_hours)
      end
    end

    context 'with only usage during holiday' do
      # Start of holiday
      let(:amr_start_date)  { Date.new(2023, 12, 16) }

      let(:weekday_usage) { 0.0 }
      # weekends during a holiday are categorised as holiday
      let(:weekend_usage) { 0.0 }
      # Usage during holidays, all usage out of hours
      let(:holiday_usage) { 16 * 48 * usage_per_hh }

      let(:expected_out_of_hours) { weekend_usage + weekday_usage + holiday_usage }

      it 'returns the expected totals' do
        usage = service.out_of_hours_kwh
        expect(usage[:total]).to eq(expected_total)
        expect(usage[:out_of_hours]).to eq(expected_out_of_hours)
        expect(usage[:total]).to eq(usage[:out_of_hours])
      end
    end
  end

  shared_examples 'a usage breakdown for December 2023' do
    let(:days) { (amr_start_date..amr_end_date).count }
    let(:expected_total_kwh) { days * 48 * usage_per_hh }

    # 11 weekdays in period of meter data
    # 48 - 16 is number of half-hourly periods in day minus number of half-hourly school is open
    # school_times defines an 8 hour day, so 16 hh periods when open
    def weekday_closed_usage_kwh
      11 * (48 - 16) * usage_per_hh
    end

    # 16 days classed as holidays
    def holiday_usage_kwh
      16 * 48 * usage_per_hh
    end

    # 4 weekends in period of meter data that aren't holidays
    def weekend_usage_kwh
      4 * 48 * usage_per_hh
    end

    def check_analysis(usage, kwh, expected_total_kwh)
      expect(usage).to have_attributes(kwh: kwh, co2: kwh * carbon_intensity, £: kwh * flat_rate)
      expect(usage.percent).to be_within(0.001).of(kwh / expected_total_kwh)
    end

    subject(:day_type_breakdown) { service.usage_breakdown }

    it 'returns the totals' do
      expect(day_type_breakdown.total.kwh).to eq expected_total_kwh
      expect(day_type_breakdown.total.co2).to eq days * 48 * carbon_intensity * usage_per_hh
    end

    it 'returns the out of hours usage analysis' do
      out_of_hours_kwh = weekend_usage_kwh + weekday_closed_usage_kwh + holiday_usage_kwh
      check_analysis(day_type_breakdown.out_of_hours, out_of_hours_kwh, expected_total_kwh)
    end

    it 'returns the holiday usage analysis' do
      check_analysis(day_type_breakdown.holiday, holiday_usage_kwh, expected_total_kwh)
    end

    it 'returns the school day closed usage analysis' do
      check_analysis(day_type_breakdown.school_day_closed, weekday_closed_usage_kwh, expected_total_kwh)
    end

    it 'returns the school day open usage analysis' do
      weekday_open_usage_kwh = 11 * 16 * usage_per_hh
      check_analysis(day_type_breakdown.school_day_open, weekday_open_usage_kwh, expected_total_kwh)
    end

    it 'returns the weekend usage analysis' do
      weekend_usage_kwh = 4 * 48 * usage_per_hh
      check_analysis(day_type_breakdown.weekend, weekend_usage_kwh, expected_total_kwh)
    end

    it 'returns the community use analysis' do
      expect(day_type_breakdown.community.kwh).to eq(0.0)
      expect(day_type_breakdown.community.co2).to eq(0.0)
      expect(day_type_breakdown.community.percent).to eq(0.0)
      expect(day_type_breakdown.community.£).to eq(0.0)
    end

    context 'when a community use time is defined' do
      # One hour each weekday
      let(:community_use_times) do
        %i[monday tuesday wednesday thursday friday].map do |day|
          {
            day: day,
            usage_type: :community_use,
            opening_time: TimeOfDay.new(15, 0),
            closing_time: TimeOfDay.new(16, 0),
            calendar_period: :term_times
          }
        end
      end

      let(:open_close_times) do
        build(
          :open_close_times,
          :from_frontend_times,
          school_times: school_times,
          holidays: build(:holidays, :with_calendar_year, year: 2023),
          community_times: community_use_times
        )
      end

      it 'returns the totals' do
        expect(day_type_breakdown.total.kwh).to eq expected_total_kwh
        expect(day_type_breakdown.total.co2).to eq days * 48 * carbon_intensity * usage_per_hh
      end

      it 'returns the community use analysis' do
        community_use_kwh = 11 * 2 * usage_per_hh
        check_analysis(day_type_breakdown.community, community_use_kwh, expected_total_kwh)
      end

      it 'returns the out of hours usage analysis' do
        weekday_closed_usage_kwh = 11 * (48 - 16 - 2) * usage_per_hh
        community_use_kwh = 11 * 2 * usage_per_hh

        out_of_hours_kwh = weekend_usage_kwh + community_use_kwh + weekday_closed_usage_kwh + holiday_usage_kwh
        check_analysis(day_type_breakdown.out_of_hours, out_of_hours_kwh, expected_total_kwh)
      end

      it 'returns the holiday usage analysis' do
        check_analysis(day_type_breakdown.holiday, holiday_usage_kwh, expected_total_kwh)
      end

      it 'returns the school day closed usage analysis' do
        weekday_closed_usage_kwh = 11 * (48 - 16 - 2) * usage_per_hh
        check_analysis(day_type_breakdown.school_day_closed, weekday_closed_usage_kwh, expected_total_kwh)
      end

      it 'returns the school day open usage analysis' do
        weekday_open_usage_kwh = 11 * 16 * usage_per_hh
        check_analysis(day_type_breakdown.school_day_open, weekday_open_usage_kwh, expected_total_kwh)
      end

      it 'returns the weekend usage analysis' do
        check_analysis(day_type_breakdown.weekend, weekend_usage_kwh, expected_total_kwh)
      end
    end
  end

  describe '#usage_breakdown' do
    context 'with electricity' do
      let(:fuel_type) { :electricity }

      it_behaves_like 'a usage breakdown for December 2023'
    end

    context 'with storage heater' do
      let(:fuel_type) { :storage_heater }

      it_behaves_like 'a usage breakdown for December 2023'
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      it_behaves_like 'a usage breakdown for December 2023'
    end
  end
end
