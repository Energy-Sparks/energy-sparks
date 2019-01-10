require 'rails_helper'

describe 'MeritUsageCalculations' do
  let(:today) { Date.today }
  let(:calendar) { create :calendar_with_terms, template: true }
  subject { create :school, calendar: calendar }
  let(:gas_meter) { create :gas_meter, school_id: subject.id }

  def generate_single_reading(single_reading)
    readings = Array.new(48, 0.0)
    readings[0] = single_reading
    readings
  end

  describe '#weekly_energy_reduction?' do
    context 'when the schools energy usage has decreased week on week' do
      it 'returns true' do
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date: today - 2.weeks, kwh_data_x48: generate_single_reading(3.0), one_day_kwh: 3.0
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date: today - 1.week, kwh_data_x48: generate_single_reading(2.0), one_day_kwh: 2.0
        expect(subject.weekly_energy_reduction?(today: today)).to be(true)
      end
    end
    context 'when the schools energy usage has increased week on week' do
      it 'returns false' do
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date: today - 2.weeks, kwh_data_x48: generate_single_reading(2.0), one_day_kwh: 2.0
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date: today - 1.week, kwh_data_x48: generate_single_reading(3.0), one_day_kwh: 3.0

        expect(subject.weekly_energy_reduction?(today: today)).to be(false)
      end
    end
  end

  describe '#gas_reduction' do
    context "when the school's gas usage has decreased by ~0.2" do
      it 'returns roughly 0.2' do
        current_term = create :term, calendar_id: subject.calendar_id, start_date: today.weeks_ago(5), end_date: today
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date: current_term.start_date.beginning_of_week(:saturday), kwh_data_x48: generate_single_reading(12.5), one_day_kwh: 12.5
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date:today.last_week(:friday), kwh_data_x48: generate_single_reading(10.0), one_day_kwh: 10.0

        expect(subject.gas_reduction).to be_within(0.1).of(0.2)
      end
    end
    context "when the school's gas usage has not decreased by ~0.2" do
      it 'returns roughly 0.2' do
        current_term = create :term, calendar_id: subject.calendar_id, start_date: today.weeks_ago(5), end_date: today
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date: current_term.start_date.beginning_of_week(:saturday).midday, kwh_data_x48: generate_single_reading(11), one_day_kwh: 11
        create :amr_validated_reading, meter_id: gas_meter.id, reading_date: today.last_week(:friday).midday, kwh_data_x48: generate_single_reading(10), one_day_kwh: 10

        expect(subject.gas_reduction).not_to be_within(0.1).of(0.2)
      end
    end
  end

  describe '#electricity_reduction' do
    context "when the school's electricity usage has decreased by ~0.2" do
      it 'returns roughly 0.2' do
        current_term = create :term, calendar_id: subject.calendar_id, start_date: today.weeks_ago(5), end_date: today

        electricity_meter = create :electricity_meter, school_id: subject.id
        create :amr_validated_reading, meter_id: electricity_meter.id, reading_date: current_term.start_date.beginning_of_week(:saturday).midday, kwh_data_x48: generate_single_reading(12.5), one_day_kwh: 12.5
        create :amr_validated_reading, meter_id: electricity_meter.id, reading_date: today.last_week(:friday).midday, kwh_data_x48: generate_single_reading(10), one_day_kwh: 10

        expect(subject.electricity_reduction).to be_within(0.1).of(0.2)
      end
    end
    context "when the school's electricity usage has not decreased by ~0.2" do
      it 'returns roughly 0.2' do
        current_term = create :term, calendar_id: subject.calendar_id, start_date: today.weeks_ago(5), end_date: today

        electricity_meter = create :electricity_meter, school_id: subject.id
        create :amr_validated_reading, meter_id: electricity_meter.id, reading_date: current_term.start_date.beginning_of_week(:saturday).midday, kwh_data_x48: generate_single_reading(11), one_day_kwh: 11
        create :amr_validated_reading, meter_id: electricity_meter.id, reading_date: today.last_week(:friday).midday, kwh_data_x48: generate_single_reading(10), one_day_kwh: 10

        expect(subject.electricity_reduction).not_to be_within(0.1).of(0.2)
      end
    end
  end

  describe '#activity_per_week?' do
    context 'when the school has logged one activity per week' do
      it 'returns true' do
        create :term, calendar_id: subject.calendar_id, start_date: today.days_ago(1), end_date: today
        create :term, calendar_id: subject.calendar_id, start_date: today.weeks_ago(5), end_date: today.days_ago(2)
        12.times { |n| create :activity, school_id: subject.id, happened_on: today.days_ago(3 * n) }

        expect(subject.activity_per_week?).to be(true)
      end
    end
    context 'when the school has not logged one activity per week' do
      it 'returns false' do
        create :term, calendar_id: subject.calendar_id, start_date: today.days_ago(1), end_date: today
        create :term, calendar_id: subject.calendar_id, start_date: today.weeks_ago(5), end_date: today.days_ago(2)
        2.times { |n| create :activity, school_id: subject.id, happened_on: today.weeks_ago(n) }

        expect(subject.activity_per_week?).to be(false)
      end
    end
  end
end
