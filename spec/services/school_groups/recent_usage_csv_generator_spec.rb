require 'rails_helper'

RSpec.describe SchoolGroups::RecentUsageCsvGenerator do
  let(:school_group) { create(:school_group) }
  let!(:school_1)    { create(:school, school_group: school_group, number_of_pupils: 10, data_enabled: true, visible: true, active: true, name: 'A school') }
  let!(:school_2)    { create(:school, school_group: school_group, number_of_pupils: 20, data_enabled: true, visible: true, active: true, name: 'B school') }

  before do
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types) { [:electricity, :gas, :storage_heaters] }
    changes = OpenStruct.new(
      change: "-16%",
      usage: '910',
      cost: '£137',
      co2: '8,540',
      change_text: "-16%",
      usage_text: '910',
      cost_text: '£137',
      co2_text: '8,540',
      has_data: true
    )
    allow_any_instance_of(School).to receive(:recent_usage) do
      OpenStruct.new(
        electricity: OpenStruct.new(week: changes, year: changes),
        gas: OpenStruct.new(week: changes, year: changes),
        storage_heaters: OpenStruct.new(week: changes, year: changes)
      )
    end
  end

  context "with school group data" do
    it 'returns change data as a csv for all schools in a school group' do
      csv = SchoolGroups::RecentUsageCsvGenerator.new(school_group: school_group.reload).export
      expect(csv.lines.count).to eq(3)
      expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
      expect(csv.lines[1]).to eq("#{school_group.schools.first.name},-16%,-16%,-16%,-16%,-16%,-16%\n")
      expect(csv.lines[2]).to eq("#{school_group.schools.second.name},-16%,-16%,-16%,-16%,-16%,-16%\n")

      csv = SchoolGroups::RecentUsageCsvGenerator.new(school_group: school_group.reload, metric: 'change').export
      expect(csv.lines.count).to eq(3)
      expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
      expect(csv.lines[1]).to eq("#{school_group.schools.first.name},-16%,-16%,-16%,-16%,-16%,-16%\n")
      expect(csv.lines[2]).to eq("#{school_group.schools.second.name},-16%,-16%,-16%,-16%,-16%,-16%\n")
    end

    it 'returns usage data as a csv for all schools in a school group' do
      csv = SchoolGroups::RecentUsageCsvGenerator.new(school_group: school_group.reload, metric: 'usage').export
      expect(csv.lines.count).to eq(3)
      expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
      expect(csv.lines[1]).to eq("#{school_group.schools.first.name},910,910,910,910,910,910\n")
      expect(csv.lines[2]).to eq("#{school_group.schools.second.name},910,910,910,910,910,910\n")
    end

    it 'returns cost data as a csv for all schools in a school group' do
      csv = SchoolGroups::RecentUsageCsvGenerator.new(school_group: school_group.reload, metric: 'cost').export
      expect(csv.lines.count).to eq(3)
      expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
      expect(csv.lines[1]).to eq("#{school_group.schools.first.name},£137,£137,£137,£137,£137,£137\n")
      expect(csv.lines[2]).to eq("#{school_group.schools.second.name},£137,£137,£137,£137,£137,£137\n")
    end

    it 'returns cost data as a csv for all schools in a school group' do
      csv = SchoolGroups::RecentUsageCsvGenerator.new(school_group: school_group.reload, metric: 'co2').export
      expect(csv.lines.count).to eq(3)
      expect(csv.lines[0]).to eq("School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n")
      expect(csv.lines[1]).to eq("#{school_group.schools.first.name},\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n")
      expect(csv.lines[2]).to eq("#{school_group.schools.second.name},\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n")
    end

    it 'returns an error if the class is initialised with an invalid metric type' do
      expect { SchoolGroups::RecentUsageCsvGenerator.new(school_group: school_group.reload, metric: 'something_invalid') }.to raise_error(StandardError)
    end
  end
end
