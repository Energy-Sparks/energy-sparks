require 'rails_helper'

RSpec.describe SchoolGroups::SchoolsPriorityActionCsvGenerator do
  let(:school_group)           { create(:school_group) }
  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10, floor_area: 200.0, data_enabled: true, visible: true, active: true) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20, floor_area: 300.0, data_enabled: true, visible: true, active: true) }

  include_context 'school group priority actions' do
    let(:school_with_saving) { school_1 }
  end

  context 'with school group data' do
    describe '#export' do
      it 'returns priority actions data as a csv for a school group' do
        csv = SchoolGroups::SchoolsPriorityActionCsvGenerator.new(schools: school_group.schools, alert_type_rating_ids: [alert_type_rating.id]).export
        expect(csv.lines.count).to eq(2)
        expect(csv.lines[0]).to eq("Fuel,Description,School,Number of pupils,Floor area (m2),Energy (kWh),Cost (£),CO2 (kg)\n")
        expect(csv.lines[1]).to eq("Gas,Spending too much money on heating,#{school_group.schools.first.name},10,200.0,0,£1000,1100\n")
      end

      context 'when including cluster' do
        subject(:csv) { SchoolGroups::SchoolsPriorityActionCsvGenerator.new(schools: school_group.schools, alert_type_rating_ids: [alert_type_rating.id], include_cluster: true).export }

        it { expect(csv.lines.count).to eq(2) }
        it { expect(csv.lines[0]).to eq("Fuel,Description,School,Cluster,Number of pupils,Floor area (m2),Energy (kWh),Cost (£),CO2 (kg)\n") }

        context "when school doesn't have cluster" do
          it { expect(csv.lines[1]).to eq("Gas,Spending too much money on heating,#{school_group.schools.first.name},Not set,10,200.0,0,£1000,1100\n") }
        end

        context 'when school has a cluster' do
          let!(:cluster) { create(:school_group_cluster, school_group: school_group, name: 'My Cluster', schools: [school_1]) }

          it { expect(csv.lines[1]).to eq("Gas,Spending too much money on heating,#{school_group.schools.first.name},My Cluster,10,200.0,0,£1000,1100\n") }
        end
      end
    end
  end
end
