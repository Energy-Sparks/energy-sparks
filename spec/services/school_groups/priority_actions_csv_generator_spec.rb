require 'rails_helper'

RSpec.describe SchoolGroups::PriorityActionsCsvGenerator do
  let(:school_group) { create(:school_group) }

  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20) }

  include_context 'school group priority actions' do
    let(:school_with_saving) { school_1 }
  end

  context 'with school group data' do
    it 'returns priority actions data as a csv for a school group' do
      school_group.reload
      csv = SchoolGroups::PriorityActionsCsvGenerator.new(schools: school_group.schools).export
      expect(csv.lines.count).to eq(2)
      expect(csv.lines[0]).to eq("Fuel,Description,Schools,Energy (kWh),Cost (£),CO2 (kg)\n")
      expect(csv.lines[1]).to eq("Gas,Spending too much money on heating,1,\"2,200\",\"£1,000\",\"1,100\"\n")
    end
  end
end
