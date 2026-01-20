# frozen_string_literal: true

require 'rails_helper'

describe Targets::TargetDates do
  subject(:target_dates) { described_class.new(aggregate_meter, Targets::TargetAttributes.new(aggregate_meter)) }

  # mock objects that will feed test data into methods
  let(:aggregate_meter) do
    instance_double(Dashboard::Meter).tap do |meter|
      allow(meter).to receive(:amr_data).and_return(amr_data)
    end
  end
  let(:amr_data) do
    instance_double(AMRData).tap do |amr_data|
      allow(amr_data).to receive_messages(start_date: amr_start_date, end_date: amr_end_date)
    end
  end
  let(:amr_start_date) { nil }
  let(:amr_end_date) { nil }

  describe '#default_target_start_date' do
    context 'when there is no data' do
      let(:this_month) { Date.new(Time.zone.today.year, Time.zone.today.month, 1) }

      it 'defaults to this month' do
        expect(described_class.default_target_start_date(aggregate_meter)).to eql this_month
      end
    end

    context 'when there is recent data' do
      # 2 years
      let(:amr_start_date)    { Time.zone.today.prev_year.prev_year }
      # arbitrary day in this month, avoid Date.today - 1.
      let(:amr_end_date)      { Time.zone.today }
      let(:this_month)        { Date.new(Time.zone.today.year, Time.zone.today.month, 1) }

      it 'defaults to this month' do
        expect(described_class.default_target_start_date(aggregate_meter)).to eql this_month
      end
    end

    context 'when the data is lagging' do
      # 2 years
      let(:amr_start_date)    { Time.zone.today.prev_year.prev_year }
      # last month
      let(:amr_end_date)      { Time.zone.today.prev_month }
      let(:last_month)        { Date.new(amr_end_date.year, amr_end_date.month, 1) }

      it 'rolls back to month of end date' do
        expect(described_class.default_target_start_date(aggregate_meter)).to eql last_month
      end
    end
  end

  describe '#one_year_of_meter_readings_available_prior_to_1st_date?' do
    context 'when no target set' do
      before do
        allow(aggregate_meter).to receive(:target_set?).and_return(false)
        allow_any_instance_of(Targets::TargetAttributes).to receive(:target_set?).and_return(false)
      end

      context 'with recent data' do
        # 2 years
        let(:amr_start_date)    { Time.zone.today.prev_year.prev_year }
        # less than a month ago
        let(:amr_end_date)      { Time.zone.today.prev_month + 10 }

        it 'reports enough data' do
          expect(target_dates.one_year_of_meter_readings_available_prior_to_1st_date?).to be true
        end
      end

      context 'with lagging data' do
        # 2 years
        let(:amr_start_date)    { Time.zone.today.prev_year.prev_year }
        # more than 30 days ago
        let(:amr_end_date)      { Time.zone.today.prev_month - 5 }

        it 'reports not enough data' do
          expect(target_dates.one_year_of_meter_readings_available_prior_to_1st_date?).to be false
        end
      end

      context 'when there is less than a year of data' do
        # 90 days
        let(:amr_start_date)    { Time.zone.today - 90 }
        let(:amr_end_date)      { Time.zone.today }

        it 'reports not enough data' do
          expect(target_dates.one_year_of_meter_readings_available_prior_to_1st_date?).to be false
        end
      end
    end
  end

  describe '#enough_holidays?' do
    context 'with limited data' do
      let(:aggregate_meter) { build(:meter_collection, :with_aggregate_meter).aggregated_electricity_meters }

      it { expect(target_dates.enough_holidays?).to be false }
    end

    context 'with limited data and target set' do
      let(:aggregate_meter) do
        build(:meter_collection, :with_aggregate_meter,
              meter_attributes: { targeting_and_tracking: [{ start_date: 1.year.ago }] })
          .aggregated_electricity_meters
      end

      it { expect(target_dates.enough_holidays?).to be false }
    end
  end
end
