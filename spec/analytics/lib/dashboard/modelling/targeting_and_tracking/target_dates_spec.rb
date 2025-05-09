# frozen_string_literal: true

require 'rails_helper'

describe TargetDates do
  # mock objects that will feed test data into methods
  let(:aggregate_meter)   { double('aggregate-meter') }
  let(:amr_data)          { double('amr-data') }

  let(:amr_start_date)        { nil }
  let(:amr_end_date)          { nil }

  before do
    allow(aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(amr_data).to receive(:start_date).and_return(amr_start_date)
    allow(amr_data).to receive(:end_date).and_return(amr_end_date)
    # allow(amr_data).to receive(:days).and_return(amr_end_date - amr_start_date)
  end

  describe '#default_target_start_date' do
    context 'when there is no data' do
      let(:this_month) { Date.new(Date.today.year, Date.today.month, 1) }

      it 'defaults to this month' do
        expect(described_class.default_target_start_date(aggregate_meter)).to eql this_month
      end
    end

    context 'when there is recent data' do
      # 2 years
      let(:amr_start_date)    { Date.today.prev_year.prev_year }
      # arbitrary day in this month, avoid Date.today - 1.
      let(:amr_end_date)      { Date.today }
      let(:this_month)        { Date.new(Date.today.year, Date.today.month, 1) }

      it 'defaults to this month' do
        expect(described_class.default_target_start_date(aggregate_meter)).to eql this_month
      end
    end

    context 'when the data is lagging' do
      # 2 years
      let(:amr_start_date)    { Date.today.prev_year.prev_year }
      # last month
      let(:amr_end_date)      { Date.today.prev_month }
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
        allow_any_instance_of(TargetAttributes).to receive(:target_set?).and_return(false)
      end

      context 'with recent data' do
        # 2 years
        let(:amr_start_date)    { Date.today.prev_year.prev_year }
        # less than a month ago
        let(:amr_end_date)      { Date.today.prev_month + 10 }

        it 'reports enough data' do
          expect(described_class.one_year_of_meter_readings_available_prior_to_1st_date?(aggregate_meter)).to be true
        end
      end

      context 'with lagging data' do
        # 2 years
        let(:amr_start_date)    { Date.today.prev_year.prev_year }
        # more than 30 days ago
        let(:amr_end_date)      { Date.today.prev_month - 5 }

        it 'reports not enough data' do
          expect(described_class.one_year_of_meter_readings_available_prior_to_1st_date?(aggregate_meter)).to be false
        end
      end

      context 'when there is less than a year of data' do
        # 90 days
        let(:amr_start_date)    { Date.today - 90 }
        let(:amr_end_date)      { Date.today }

        it 'reports not enough data' do
          expect(described_class.one_year_of_meter_readings_available_prior_to_1st_date?(aggregate_meter)).to be false
        end
      end
    end
  end
end
