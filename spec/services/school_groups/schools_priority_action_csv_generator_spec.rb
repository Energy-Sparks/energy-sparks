require 'rails_helper'

RSpec.describe SchoolGroups::SchoolsPriorityActionCsvGenerator do
  let(:school_group) { create(:school_group) }

  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10, data_enabled: true, visible: true, active: true) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20, data_enabled: true, visible: true, active: true) }

  let!(:alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
  let!(:alert_type_rating) do
    create(
      :alert_type_rating,
      alert_type: alert_type,
      rating_from: 6.1,
      rating_to: 10,
      management_priorities_active: true,
      description: "high"
    )
  end
  let!(:alert_type_rating_content_version) do
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating,
      management_priorities_title: 'Spending too much money on heating',
    )
  end
  let(:saving) do
    OpenStruct.new(
      school: school_1,
      one_year_saving_kwh: 0,
      average_one_year_saving_gbp: 1000,
      one_year_saving_co2: 1100
    )
  end
  let(:priority_actions) do
    {
      alert_type_rating => [saving]
    }
  end
  let(:total_saving) do
    OpenStruct.new(
      schools: [school_1],
      average_one_year_saving_gbp: 1000,
      one_year_saving_co2: 1100,
      one_year_saving_kwh: 2200
    )
  end
  let(:total_savings) do
    {
      alert_type_rating => total_saving
    }
  end

  before(:each) do
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:priority_actions).and_return(priority_actions)
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:total_savings).and_return(total_savings)
  end

  context "with school group data" do
    describe '#export' do
      it 'returns priority actions data as a csv for a school group' do
        csv = SchoolGroups::SchoolsPriorityActionCsvGenerator.new(school_group: school_group, alert_type_rating_ids: [alert_type_rating.id]).export
        expect(csv.lines.count).to eq(2)
        expect(csv.lines[0]).to eq("Fuel,Description,School,Energy saving,Cost saving,CO2 reduction\n")
        expect(csv.lines[1]).to eq("Gas,Spending too much money on heating,#{school_group.schools.first.name},0 kWh,£1000,1100 kg CO2\n")
      end
    end
  end
end
