require 'rails_helper'

module Schools
  describe GenerateFuelConfiguration do

    let(:today)    { Time.zone.today }
    let(:calendar) { create :calendar, template: true }
    let!(:school)  { create :school, :with_school_group, calendar: calendar }

    before(:each) do
      GenerateFuelConfiguration.new(school).generate
    end

    describe '#fuel_types_for_analysis?' do
      it 'gas and electricity' do
        meter  = create(:electricity_meter_with_validated_reading, school: school, reading_count: 1)
        meter2 = create(:gas_meter_with_validated_reading, school: school, reading_count: 1)

        fuel_config = GenerateFuelConfiguration.new(school).generate

        expect(fuel_config.fuel_types_for_analysis).to be :electric_and_gas
        expect(fuel_config.dual_fuel).to be true
        expect(fuel_config.no_meters_with_validated_readings).to be false
        expect(fuel_config.has_gas).to be true
      end

      it 'electricity' do
        meter = create(:electricity_meter_with_validated_reading, school: school, reading_count: 1)

        fuel_config = GenerateFuelConfiguration.new(school).generate

        expect(fuel_config.fuel_types_for_analysis).to be :electric_only
        expect(fuel_config.dual_fuel).to be false
        expect(fuel_config.no_meters_with_validated_readings).to be false
        expect(fuel_config.has_gas).to be false
      end

      it 'gas' do
        meter = create(:gas_meter_with_validated_reading, school: school, reading_count: 1)

        fuel_config = GenerateFuelConfiguration.new(school).generate
        expect(fuel_config.fuel_types_for_analysis).to be :gas_only
        expect(fuel_config.has_gas).to be true
      end
    end
  end
end
