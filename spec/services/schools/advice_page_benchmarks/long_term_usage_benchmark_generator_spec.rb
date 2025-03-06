require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::LongTermUsageBenchmarkGenerator, type: :service do
  subject(:service) do
    described_class.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)
  end

  let(:advice_page) { create(:advice_page, key: :electricity_long_term, fuel_type: :electricity) }
  let(:reading_start_date) { 1.year.ago }
  let(:school) do
    school = create(:school, :with_school_group, :with_fuel_configuration, number_of_pupils: 100)
    create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
    create(:electricity_meter_with_validated_reading_dates,
           school: school, start_date: reading_start_date, end_date: Time.zone.today, reading: 1.25)
    school
  end
  let(:aggregate_school) { AggregateSchoolService.new(school).aggregate_school }

  describe '#benchmark_school' do
    context 'not enough data' do
      let(:reading_start_date) { 30.days.ago }

      it 'does not benchmark' do
        expect(service.benchmark_school).to be_nil
      end
    end

    context 'with enough data' do
      it 'returns the comparison category' do
        expect(service.benchmark_school).to eq :benchmark_school
      end
    end
  end
end
