require 'rails_helper'

RSpec.describe SchoolTarget, type: :model do
  let(:school)          { create(:school) }
  let(:start_date)      { Time.zone.today.beginning_of_month}
  let(:target_date)     { Time.zone.today.beginning_of_month.next_year}

  context 'when saving' do
    before do
      school.school_targets.create!(start_date: start_date, target_date: target_date, electricity: 10)
    end

    it 'saves given start and end dates' do
      expect(SchoolTarget.first.start_date).to eq start_date
      expect(SchoolTarget.first.target_date).to eq target_date
    end

    it 'creates an observation' do
      expect(Observation.first.observation_type).to eq 'school_target'
      expect(Observation.first.observable).to eq SchoolTarget.first
      expect(Observation.first.school).to eq school
      expect(Observation.first.points).to eq 10

      # creates only a single Observation
      SchoolTarget.first.update!(electricity: 22)
      expect(Observation.count).to eq 1
    end

    context 'and dates are mismatched' do
      let(:start_date) { Time.zone.today.last_year }

      it 'ensures end date is 12 months from start' do
        expect(SchoolTarget.first.start_date).to eq start_date
        expect(SchoolTarget.first.target_date).to eq start_date.next_year
      end
    end
  end

  context 'when updating' do
    before do
      school.school_targets.create!(start_date: start_date, target_date: target_date, electricity: 10)
    end

    it 'updates the observation date' do
      expect(Observation.first.at.to_date).to eql SchoolTarget.first.start_date
      SchoolTarget.first.update!(start_date: Time.zone.today.beginning_of_month.prev_month)
      expect(Observation.first.at.to_date).to eql SchoolTarget.first.start_date
    end
  end

  context 'when validating' do
    it 'requires target and start dates' do
      target = SchoolTarget.new({ school: school, electricity: 10 })
      expect(target.valid?).to be false
    end

    it 'requires a least one target' do
      target = SchoolTarget.new({ school: school, start_date: start_date, target_date: target_date })
      expect(target.valid?).to be false
    end

    it 'allows nil values for some targets' do
      target = SchoolTarget.new({ school: school, start_date: start_date, target_date: target_date, electricity: 10 })
      expect(target.valid?).to be true

      target = SchoolTarget.new({ school: school, start_date: start_date, target_date: target_date, gas: 10 })
      expect(target.valid?).to be true

      target = SchoolTarget.new({ school: school, start_date: start_date, target_date: target_date, storage_heaters: 10 })
      expect(target.valid?).to be true
    end
  end

  context 'when finding current target' do
    it 'knows if its current' do
      target = SchoolTarget.new({ school: school, electricity: 10, start_date: start_date, target_date: target_date })
      expect(target.current?).to be true

      target = SchoolTarget.new({ school: school, electricity: 10, start_date: start_date, target_date: Time.zone.today.last_year })
      expect(target.current?).to be false

      target = SchoolTarget.new({ school: school, electricity: 10, start_date: Date.tomorrow, target_date: target_date })
      expect(target.current?).to be false
    end
  end

  context 'when converting to meter attributes' do
    let(:school)      { create(:school) }
    let(:target)      { create(:school_target, school: school, electricity: 10.0, gas: 5.0, storage_heaters: 7.0) }

    it 'generates aggregated electricity attribute' do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_electricity_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.start_date)
      expect(attribute[:targeting_and_tracking][0][:target]).to be(0.9)
    end

    it 'generates aggregated gas attribute' do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_gas_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.start_date)
      expect(attribute[:targeting_and_tracking][0][:target]).to be(0.95)
    end

    it 'generates aggregated storage attribute' do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_storage_heaters_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.start_date)
      expect(attribute[:targeting_and_tracking][0][:target]).to be(0.93)
    end

    it 'generates all attributes when provided' do
      attributes = target.meter_attributes_by_meter_type
      expect(attributes[:aggregated_electricity]).not_to be_empty
      expect(attributes[:aggregated_gas]).not_to be_empty
      expect(attributes[:storage_heater_aggregated]).not_to be_empty
    end
  end
end
