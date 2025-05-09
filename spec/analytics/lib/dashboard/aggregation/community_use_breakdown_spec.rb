# frozen_string_literal: true

require 'rails_helper'

describe CommunityUseBreakdown do
  let(:kwh_data_x48)    { Array.new(48) { rand(0.0..1.0).round(2) } }
  let(:amr_start_date)  { Date.new(2023, 10, 1) }
  let(:amr_end_date)    { Date.new(2023, 10, 31) }

  let(:amr_data)     { build(:amr_data, :with_date_range, start_date: amr_start_date, end_date: amr_end_date, kwh_data_x48: kwh_data_x48) }
  let(:meter)        { build(:meter, type: :electricity, amr_data: amr_data) }
  let(:holidays)     { build(:holidays, :with_calendar_year) }

  let(:school_times) do
    [{ day: :monday, usage_type: :school_day, opening_time: TimeOfDay.new(7, 30), closing_time: TimeOfDay.new(16, 20), calendar_period: :term_times }]
  end

  let(:open_close_times)      { OpenCloseTimes.convert_frontend_times(school_times, community_use_times, holidays) }
  let(:open_close_breakdown)  { described_class.new(meter, open_close_times) }

  before do
    meter.amr_data.open_close_breakdown = open_close_breakdown
    travel_to(Date.new(2024, 12, 1))
  end

  describe '#days_kwh_x48' do
    let(:community_use_times)   { [] }
    let(:community_use)         { nil }
    let(:last_year)             { Date.today.year - 1 }
    # to match Autumn holiday in holidays factory
    let(:day)                   { Date.new(last_year, 10, 16) }

    let(:days_kwh_x48)          { open_close_breakdown.days_kwh_x48(day, :kwh, community_use: community_use) }

    context 'with no community use time period' do
      context 'with default filter' do
        it 'returns just an opening and closing time breakdown' do
          expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open])
          expect(days_kwh_x48.values.all? { |v| v.size == 48 }).to eq true
        end

        it 'returns the same total as the amr_data class' do
          expect(days_kwh_x48.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.days_kwh_x48(day).sum)
        end
      end
    end

    context 'with single community use time period' do
      # The times correspond to the HH index starting at 38 and ending at 42 (exclusive range), so 5 periods in total
      let(:community_use_times) do
        [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(19, 0), closing_time: TimeOfDay.new(21, 30), calendar_period: :term_times }]
      end

      context 'with default filter' do
        it 'returns a breakdown of all periods' do
          expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
        end

        it 'returns the same total as the amr_data class' do
          expect(days_kwh_x48.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.days_kwh_x48(day).sum)
        end

        context 'when the usage in the community use period is below the baseload' do
          # a 48 low hh readings where the usage in the community use period will be lower than the baseload for rest of the day
          # community use is 5 HH periods, the statistical baseload calculator will use the lowest 8 HH periods,
          # so the calculated baseload for this day is guaranteed to be higher than the community use consumption
          let(:low_usage)               { Array.new(38) { 1.0 } + Array.new(5) { 0.1 } + Array.new(5) { 1.0 } }
          let(:low_usage_reading)       { build(:one_day_amr_reading, date: day, kwh_data_x48: low_usage) }

          before do
            amr_data.add(day, low_usage_reading)
          end

          it 'returns the expected breakdown for the day' do
            expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community_baseload])
          end

          it 'allocates all the usage to community baseload use during the community use period' do
            # 6.30pm (37) all usage is school day closed
            expect(days_kwh_x48[:school_day_closed][37]).to eq(1.0)
            # 7.00pm (38) to period ending at 21:30 (42) is community use, so no school day closed usage
            expect(days_kwh_x48[:school_day_closed][38..42]).to eq(Array.new(5, 0.0))
            # all usage here is community use
            expect(days_kwh_x48[:community_baseload][38..42]).to eq(Array.new(5, 0.1))
            # 21.30pm (43) all usage is school day closed again
            expect(days_kwh_x48[:school_day_closed][43]).to eq(1.0)
          end
        end
      end

      context 'when end of school day marks start of community use time' do
        let(:kwh_data_x48) { Array.new(48) { 1.0 } }

        let(:school_times) do
          [{ day: :monday, usage_type: :school_day, opening_time: TimeOfDay.new(7, 30), closing_time: TimeOfDay.new(16, 15), calendar_period: :term_times }]
        end

        let(:community_use_times) do
          [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(16, 15), closing_time: TimeOfDay.new(21, 0), calendar_period: :term_times }]
        end

        it 'returns the expected breakdown for the day' do
          expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community_baseload])
        end

        it 'splits the usage at 16:00 between community baseload and school day' do
          expect(days_kwh_x48[:school_day_open][32]).to eq 0.5
          expect(days_kwh_x48[:community_baseload][32]).to eq 0.5
        end

        context 'with the usage in the community use period is below the daily baseload' do
          # this has low usage for half hourly period indexes 31, 32 which is 16:00 and 16:30
          # daily baseload will be higher than 0.1. Testing to ensure that the period with consumption
          # at 0.1 is correct
          let(:kwh_data_x48) { Array.new(31) { 1.0 } + Array.new(2) { 0.1 } + Array.new(15) { 1.0 } }

          it 'returns the expected breakdown across the day' do
            expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community_baseload community])
          end

          it 'splits the usage at 16:00 between community baseload and school day' do
            expect(days_kwh_x48[:school_day_open][32]).to eq 0.05
            expect(days_kwh_x48[:community_baseload][32]).to eq 0.05
          end
        end
      end

      context 'when there is a gap between end of school day and community use time' do
        let(:kwh_data_x48) { Array.new(48) { 1.0 } }

        let(:school_times) do
          [{ day: :monday, usage_type: :school_day, opening_time: TimeOfDay.new(7, 30), closing_time: TimeOfDay.new(16, 10), calendar_period: :term_times }]
        end

        let(:community_use_times) do
          [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(16, 15), closing_time: TimeOfDay.new(21, 0), calendar_period: :term_times }]
        end

        it 'returns the expected breakdown across the day' do
          expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community_baseload])
        end

        it 'splits the usage at 16:00 between community baseload, school day open and closed' do
          # we are open for 10 minutes
          expect(days_kwh_x48[:school_day_open][32].round(2)).to eq(0.33)
          # closed for 5 minutes
          expect(days_kwh_x48[:school_day_closed][32].round(2)).to eq(0.17)
          # community use for 15 minutes
          expect(days_kwh_x48[:community_baseload][32]).to eq 0.5
        end

        context 'with the usage in the community use period is below the daily baseload' do
          # this has low usage for half hourly period indexes 31, 32 which is 16:00 and 16:30
          # daily baseload will be higher than 0.1. Testing to ensure that the period with consumption
          # at 0.1 is correct
          let(:low_usage)               { Array.new(31) { 1.0 } + Array.new(2) { 0.1 } + Array.new(15) { 1.0 } }
          let(:low_usage_reading)       { build(:one_day_amr_reading, date: day, kwh_data_x48: low_usage) }

          before do
            amr_data.add(day, low_usage_reading)
          end

          it 'returns the expected breakdown for the day' do
            expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community_baseload community])
          end

          it 'splits the usage at 16:00 between community baseload and school day' do
            # we are open for 10 minutes
            expect(days_kwh_x48[:school_day_open][32].round(3)).to eq(0.033)
            # closed for 5 minutes
            expect(days_kwh_x48[:school_day_closed][32].round(3)).to eq(0.017)
            # community use for 15 minutes
            expect(days_kwh_x48[:community_baseload][32]).to eq 0.05
          end
        end
      end

      context 'when a filter is specified' do
        let(:community_use) do
          {
            filter: filter,
            aggregate: :none,
            split_electricity_baseload: true
          }
        end

        context 'with :community_only filter' do
          let(:filter) { :community_only }

          it 'returns a breakdown of just the community use' do
            expect(days_kwh_x48.keys).to match_array(%i[community community_baseload])
          end
        end

        context 'with :school_only filter' do
          let(:filter) { :school_only }

          it 'returns a breakdown of just the school day' do
            expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open])
          end
        end

        context 'with :all filter' do
          let(:filter) { :all }

          it 'returns a breakdown of all periods' do
            expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
          end

          it 'returns the same total as the amr_data class' do
            expect(days_kwh_x48.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.days_kwh_x48(day).sum)
          end
        end
      end

      context 'when aggregating' do
        let(:split_electricity_baseload) { true }
        # :none is tested in previous specs
        let(:community_use) do
          {
            filter: :all,
            aggregate: aggregate,
            split_electricity_baseload: split_electricity_baseload
          }
        end

        context 'with :community_use' do
          let(:aggregate) { :community_use }

          context 'when splitting out baseload' do
            it 'does not apply a sum, as its unnecessary' do
              not_aggregated = open_close_breakdown.days_kwh_x48(day, :kwh, community_use: nil)
              expect(days_kwh_x48[:community].sum).to be_within(0.0001).of(not_aggregated[:community].sum)
            end

            it 'includes the baseload' do
              expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
            end
          end

          context 'when not splitting out baseload' do
            let(:split_electricity_baseload)  { false }

            it 'sumses the community use into :community' do
              not_aggregated = open_close_breakdown.days_kwh_x48(day, :kwh, community_use: nil)
              expected_sum = not_aggregated[:community].sum + not_aggregated[:community_baseload].sum
              expect(days_kwh_x48[:community].sum).to be_within(0.0001).of(expected_sum)
            end

            it 'does not include the baseload' do
              expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community])
            end
          end
        end

        context 'with :all_to_single_value' do
          let(:aggregate) { :all_to_single_value }

          it 'returns an array with same total as the amr_data class' do
            expect(days_kwh_x48.sum).to be_within(0.0001).of(meter.amr_data.days_kwh_x48(day).sum)
          end
        end
      end
    end

    context 'with multiple community use times' do
      let(:community_use_times)          do
        [
          { day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(6, 0), closing_time: TimeOfDay.new(7, 30), calendar_period: :term_times },
          { day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(19, 0), closing_time: TimeOfDay.new(21, 30), calendar_period: :term_times }
        ]
      end

      context 'with default filter' do
        it 'returns a breakdown of all periods' do
          expect(days_kwh_x48.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
        end

        it 'returns the same total as the amr_data class' do
          expect(days_kwh_x48.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.days_kwh_x48(day).sum)
        end
      end
    end
  end

  describe '#one_day_kwh' do
    let(:community_use_times)   { [] }
    let(:community_use)         { nil }
    let(:last_year)             { Date.today.year - 1 }
    # to match Autumn holiday in holidays factory
    let(:day)                   { Date.new(last_year, 10, 16) }

    let(:one_day_kwh)          { open_close_breakdown.one_day_kwh(day, :kwh, community_use: community_use) }

    context 'with no community use time period' do
      context 'with default filter' do
        it 'returns the same total as the amr_data class' do
          expect(one_day_kwh.values.sum).to be_within(0.0001).of(meter.amr_data.one_day_kwh(day))
        end
      end
    end

    context 'with single community use time period' do
      let(:community_use_times) do
        [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(19, 0), closing_time: TimeOfDay.new(21, 30), calendar_period: :term_times }]
      end

      context 'with default filter' do
        it 'returns a breakdown of all periods' do
          expect(one_day_kwh.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
        end

        it 'returns the same total as the amr_data class' do
          expect(one_day_kwh.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.one_day_kwh(day))
        end
      end

      context 'with a filter' do
        let(:community_use) do
          {
            filter: filter,
            aggregate: :none,
            split_electricity_baseload: true
          }
        end

        context 'with :community_only filter' do
          let(:filter) { :community_only }

          it 'returns a breakdown of just the community use' do
            expect(one_day_kwh.keys).to match_array(%i[community community_baseload])
          end
        end

        context 'with :school_only filter' do
          let(:filter) { :school_only }

          it 'returns a breakdown of just the school day' do
            expect(one_day_kwh.keys).to match_array(%i[school_day_closed school_day_open])
          end
        end

        context 'with :all filter' do
          let(:filter) { :all }

          it 'returns a breakdown of all periods' do
            expect(one_day_kwh.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
          end

          it 'returns the same total as the amr_data class' do
            expect(one_day_kwh.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.one_day_kwh(day))
          end
        end
      end

      context 'when aggregating' do
        let(:split_electricity_baseload) { true }
        # :none is tested in previous specs
        let(:community_use) do
          {
            filter: :all,
            aggregate: aggregate,
            split_electricity_baseload: split_electricity_baseload
          }
        end

        context 'with :community_use' do
          let(:aggregate) { :community_use }

          context 'when splitting out baseload' do
            it 'does not apply a sum, as its unnecessary' do
              not_aggregated = open_close_breakdown.one_day_kwh(day, :kwh, community_use: nil)
              expect(one_day_kwh[:community]).to be_within(0.0001).of(not_aggregated[:community])
            end

            it 'includes the baseload' do
              expect(one_day_kwh.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
            end
          end

          context 'when not splitting out baseload' do
            let(:split_electricity_baseload) { false }

            it 'sums the community use into :community' do
              not_aggregated = open_close_breakdown.one_day_kwh(day, :kwh, community_use: nil)
              expected_sum = not_aggregated[:community] + not_aggregated[:community_baseload]
              expect(one_day_kwh[:community]).to be_within(0.0001).of(expected_sum)
            end

            it 'does not include the baseload' do
              expect(one_day_kwh.keys).to match_array(%i[school_day_closed school_day_open community])
            end
          end
        end

        context 'with :all_to_single_value' do
          let(:aggregate) { :all_to_single_value }

          it 'returns an array with same total as the amr_data class' do
            expect(one_day_kwh).to be_within(0.0001).of(meter.amr_data.one_day_kwh(day))
          end
        end
      end
    end
  end

  describe '#kwh_date_range' do
    let(:community_use_times)   { [] }
    let(:community_use)         { nil }
    # Should cover a weekend
    let(:last_year)             { Date.today.year - 1 }
    # to match Autumn holiday in holidays factory
    let(:start_date)            { Date.new(last_year, 10, 16) - 7 }
    let(:end_date)              { Date.new(last_year, 10, 16) }

    let(:kwh_date_range)        { open_close_breakdown.kwh_date_range(start_date, end_date, :kwh, community_use: community_use) }

    context 'with no community use time period' do
      context 'with default filter' do
        it 'returns the same total as the amr_data class' do
          expect(kwh_date_range.values.sum).to be_within(0.0001).of(meter.amr_data.kwh_date_range(start_date, end_date))
        end
      end
    end

    context 'with single community use time period' do
      let(:community_use_times) do
        [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(19, 0), closing_time: TimeOfDay.new(21, 30), calendar_period: :term_times }]
      end

      context 'with default filter' do
        it 'returns the breakdown of all periods' do
          expect(kwh_date_range.keys).to match_array(%i[school_day_closed school_day_open community community_baseload weekend])
        end

        it 'returns the same total as the amr_data class' do
          expect(kwh_date_range.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.kwh_date_range(start_date, end_date))
        end
      end
    end
  end

  describe '#kwh' do
    let(:community_use_times)   { [] }
    let(:community_use)         { { filter: :all, aggregate: :none } }
    let(:last_year)             { Date.today.year - 1 }
    # to match Autumn holiday in holidays factory
    let(:day)                   { Date.new(last_year, 10, 16) }
    let(:hh_index)              { 12 }

    let(:kwh) { open_close_breakdown.kwh(day, hh_index, :kwh, community_use: community_use) }

    context 'with no community use time period' do
      context 'with default filter' do
        it 'returns the same total as the amr_data class' do
          expect(kwh.values.sum).to be_within(0.0001).of(meter.amr_data.kwh(day, hh_index))
        end
      end
    end

    context 'with single community use time period' do
      let(:community_use_times) do
        [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(19, 0), closing_time: TimeOfDay.new(21, 30), calendar_period: :term_times }]
      end

      context 'with default filter' do
        it 'returns a breakdown of all periods' do
          expect(kwh.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
        end

        it 'returns the same total as the amr_data class' do
          expect(kwh.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.kwh(day, hh_index))
        end
      end

      context 'with a filter' do
        let(:community_use) do
          {
            filter: filter,
            aggregate: :none,
            split_electricity_baseload: true
          }
        end

        context 'with :community_only filter' do
          let(:filter) { :community_only }

          it 'returns a breakdown of just the community use' do
            expect(kwh.keys).to match_array(%i[community community_baseload])
          end
        end

        context 'with :school_only filter' do
          let(:filter) { :school_only }

          it 'returns a breakdown of just the school day' do
            expect(kwh.keys).to match_array(%i[school_day_closed school_day_open])
          end
        end

        context 'with :all filter' do
          let(:filter) { :all }

          it 'returns a breakdown of all periods' do
            expect(kwh.keys).to match_array(%i[school_day_closed school_day_open community community_baseload])
          end

          it 'returns the same total as the amr_data class' do
            expect(kwh.values.flatten.sum).to be_within(0.0001).of(meter.amr_data.kwh(day, hh_index))
          end
        end
      end
    end
  end

  describe '#series_names' do
    let(:community_use_times) { [] }

    context 'with no community use time period' do
      it 'returns the default series' do
        expect(open_close_breakdown.series_names(nil)).to match_array(%i[school_day_closed school_day_open holiday weekend])
      end
    end

    context 'with a single community use time period' do
      let(:community_use_times) do
        [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(19, 0), closing_time: TimeOfDay.new(21, 30), calendar_period: :term_times }]
      end

      it 'includes the community use series' do
        expect(open_close_breakdown.series_names(nil)).to match_array(%i[school_day_closed school_day_open holiday weekend community])
      end
    end
  end
end
