require 'rails_helper'

RSpec.describe SchoolGroups::RecentUsageCsvGenerator do
  let(:school_group) { create(:school_group) }
  let!(:school_1)    { create(:school, school_group: school_group, number_of_pupils: 10, data_enabled: true, visible: true, active: true, name: 'A school') }
  let!(:school_2)    { create(:school, school_group: school_group, number_of_pupils: 20, data_enabled: true, visible: true, active: true, name: 'B school') }
  let!(:cluster)     { create(:school_group_cluster, name: "A Cluster", school_group: school_group, schools: [school_1]) }

  include_context "school group recent usage"

  shared_examples "a school group recent usage csv including cluster" do
    context "when include cluster is set to true" do
      let(:include_cluster) { true }
      it { expect(csv.lines.count).to eq(3) }
      it { expect(csv.lines[0]).to start_with("School,Cluster,")}
      it { expect(csv.lines[1]).to start_with("#{school_group.schools.first.name},A Cluster,")}
      it { expect(csv.lines[2]).to start_with("#{school_group.schools.second.name},N/A,")}
    end
  end

  let(:metric)          { }
  let(:include_cluster) { false }
  let(:params_full)     { { school_group: school_group.reload, include_cluster: include_cluster, metric: metric } }
  let(:params)  { params_full }

  subject(:csv) { SchoolGroups::RecentUsageCsvGenerator.new(**params).export }

  context "returning data" do
    context "with no metric" do
      let(:params) { params_full.except(:metric) }
      it "returns change data as a csv for all schools in a school group" do
        expect(csv.lines.count).to eq(3)
        expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
        expect(csv.lines[1]).to eq("#{school_group.schools.first.name},-16%,-16%,-16%,-16%,-16%,-16%\n")
        expect(csv.lines[2]).to eq("#{school_group.schools.second.name},-16%,-16%,-16%,-16%,-16%,-16%\n")
      end
      it_behaves_like "a school group recent usage csv including cluster"
    end

    context "with metric set to change" do
      let(:metric) { 'change' }
      it "returns change data as a csv for all schools in a school group" do
        expect(csv.lines.count).to eq(3)
        expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
        expect(csv.lines[1]).to eq("#{school_group.schools.first.name},-16%,-16%,-16%,-16%,-16%,-16%\n")
        expect(csv.lines[2]).to eq("#{school_group.schools.second.name},-16%,-16%,-16%,-16%,-16%,-16%\n")
      end
      it_behaves_like "a school group recent usage csv including cluster"
    end

    context "with metric set to usage" do
      let(:metric) { 'usage' }
      it 'returns usage data as a csv for all schools in a school group' do
        expect(csv.lines.count).to eq(3)
        expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
        expect(csv.lines[1]).to eq("#{school_group.schools.first.name},910,910,910,910,910,910\n")
        expect(csv.lines[2]).to eq("#{school_group.schools.second.name},910,910,910,910,910,910\n")
      end
      it_behaves_like "a school group recent usage csv including cluster"
    end

    context "with metric set to cost" do
      let(:metric) { 'cost' }
      it 'returns cost data as a csv for all schools in a school group' do
        expect(csv.lines.count).to eq(3)
        expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
        expect(csv.lines[1]).to eq("#{school_group.schools.first.name},£137,£137,£137,£137,£137,£137\n")
        expect(csv.lines[2]).to eq("#{school_group.schools.second.name},£137,£137,£137,£137,£137,£137\n")
      end
      it_behaves_like "a school group recent usage csv including cluster"
    end

    context "with metric set to co2" do
      let(:metric) { 'co2' }
      it 'returns co2 data as a csv for all schools in a school group' do
        expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
        expect(csv.lines[1]).to eq("#{school_group.schools.first.name},\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n")
        expect(csv.lines[2]).to eq("#{school_group.schools.second.name},\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n")
      end
      it_behaves_like "a school group recent usage csv including cluster"
    end
  end

  it 'returns an error if the class is initialised with an invalid metric type' do
    expect { SchoolGroups::RecentUsageCsvGenerator.new(school_group: school_group.reload, metric: 'something_invalid') }.to raise_error(StandardError)
  end
end
