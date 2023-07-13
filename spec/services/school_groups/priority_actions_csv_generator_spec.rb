require 'rails_helper'

RSpec.describe SchoolGroups::PriorityActionsCsvGenerator do
  let(:school_group) { create(:school_group) }

  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10, data_enabled: true, visible: true, active: true) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20, data_enabled: true, visible: true, active: true) }

  include_context "school group priority actions"

  context "with school group data" do
    it 'returns priority actions data as a csv for a school group' do
      csv = SchoolGroups::PriorityActionsCsvGenerator.new(school_group: school_group.reload).export
      expect(csv.lines.count).to eq(2)
      expect(csv.lines[0]).to eq("Fuel,Description,Schools,Energy saving,Cost saving,CO2 reduction\n")
      expect(csv.lines[1]).to eq("Gas,Spending too much money on heating,1,\"2,200 kWh\",\"£1,000\",\"1,100 kg CO2\"\n")
    end
  end
end
