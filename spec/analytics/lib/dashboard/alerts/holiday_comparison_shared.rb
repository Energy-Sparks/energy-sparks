# frozen_string_literal: true

require_relative 'non_estimated_readings_shared'

shared_examples 'an EST-aware holiday-to-holiday comparison' do |fuel_type:, reporting_period:|
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with estimated reading helpers'

  let(:amr_start_date) { Date.new(2022, 1, 1) }
  let(:amr_end_date) { Date.new(2023, 10, 29) }
  let(:holidays) do
    Holidays.new([
                   build(:holiday, name: 'Autumn half term',
                                   start_date: Date.new(2022, 10, 22), end_date: Date.new(2022, 10, 30)),
                   build(:holiday, name: 'Summer',
                                   start_date: Date.new(2023, 7, 22), end_date: Date.new(2023, 8, 31)),
                   build(:holiday, name: 'Autumn half term',
                                   start_date: Date.new(2023, 10, 21), end_date: amr_end_date)
                 ])
  end
  let(:meter_collection) do
    build(:meter_collection, :with_aggregate_meter,
          fuel_type:, start_date: amr_start_date, end_date: amr_end_date, holidays:)
  end
  let(:amr_data) { meter_collection.aggregate_meter(fuel_type).amr_data }
  let(:periods) { alert.send(:last_two_periods, amr_end_date) }

  before do
    travel_to amr_end_date
    allow(meter_collection).to receive(:storage_heaters?).and_return(true) if fuel_type == :storage_heaters
  end

  it 'selects the intended holiday comparison', :aggregate_failures do
    current, previous = periods

    expect(alert.reporting_period).to eq(reporting_period)
    expect(current.type).to eq(:autumn_half_term)
    expect(current.start_date.year).to eq(2023)
    expect(previous.type).to eq(reporting_period == :same_holidays ? :autumn_half_term : :summer)
    expect(previous.start_date.year).to eq(reporting_period == :same_holidays ? 2022 : 2023)
  end

  describe '#enough_data' do
    it 'accepts non-estimated readings in both holidays' do
      expect(alert.enough_data(amr_end_date)).to eq(:enough)
    end

    %i[current previous].each_with_index do |name, index|
      context "when checking the #{name} holiday independently" do
        let(:period) { periods.fetch(index) }
        let(:dates) { (period.start_date..period.end_date).to_a }
        let(:weekdays) { dates.reject { |date| date.saturday? || date.sunday? } }

        it 'rejects a holiday with only estimated readings' do
          dates.each { |date| amr_data[date].set_type('EST') }

          expect(alert.enough_data(amr_end_date)).to eq(:not_enough)
        end

        it 'accepts exactly four non-estimated weekdays' do
          weekdays.drop(4).each { |date| amr_data[date].set_type('EST') }

          expect(alert.enough_data(amr_end_date)).to eq(:enough)
        end

        it 'rejects exactly three non-estimated weekdays despite original weekend readings' do
          weekdays.drop(3).each { |date| amr_data[date].set_type('EST') }

          expect(alert.enough_data(amr_end_date)).to eq(:not_enough)
        end

        it 'does not count missing weekdays towards the four-day minimum' do
          weekdays.drop(4).each { |date| amr_data[date].set_type('EST') }
          amr_data.delete(weekdays.fetch(3))

          expect(alert.enough_data(amr_end_date)).to eq(:not_enough)
        end

        it 'rejects missing weekdays even when all weekend readings are present' do
          weekdays.each { |date| amr_data.delete(date) }

          expect(alert.enough_data(amr_end_date)).to eq(:not_enough)
        end

        it 'does not count original weekend readings when all weekdays are estimated' do
          weekdays.each { |date| amr_data[date].set_type('EST') }

          expect(alert.enough_data(amr_end_date)).to eq(:not_enough)
        end

        it 'counts corrected non-EST weekdays towards the minimum' do
          weekdays.each_with_index { |date, i| amr_data[date].set_type(i < 4 ? 'AGGR' : 'EST') }

          expect(alert.enough_data(amr_end_date)).to eq(:enough)
        end
      end
    end
  end

  it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 60
end
