require 'rails_helper'

RSpec.describe SchoolGroups::CsvGenerator do
  def create_data_for_school_groups(school_groups)
    school_groups.each do |school_group|
      School.school_types.each_key do |school_type|
        create :school, visible: true, data_enabled: true, school_group: school_group, school_type: school_type
        invisible = create :school, visible: false, school_group: school_group, school_type: school_type
        create :school, active: false, school_group: school_group, school_type: school_type
        create :school_onboarding, school_group: school_group, school: invisible
      end
    end
  end

  context 'with school group data' do
    let(:school_groups) { 2.times.collect { create(:school_group) } }
    let(:header) { 'School group,Group type,School type,Onboarding,Active,Data visible,Invisible,Removed' }
    subject(:data) { SchoolGroups::CsvGenerator.new(school_groups).export_detail }

    let(:line_count) { 1 + (School.school_types.length * school_groups.length) + school_groups.length + 1 }

    before do
      create_data_for_school_groups(school_groups)
    end

    it { expect(data.lines.count).to eq(line_count) }
    it { expect(data.lines.first.chomp).to eq(header) }

    it 'returns exported detail' do
      i = 1
      school_groups.each do |school_group|
        School.school_types.each_key do |school_type|
          expect(data.lines[i].chomp).to eq([school_group.name, school_group.group_type.humanize, school_type.humanize, 1, 1, 1, 1, 1].join(','))
          i += 1
        end
        expect(data.lines[i].chomp).to eq([school_group.name, school_group.group_type.humanize, 'All school types', 7, 7, 7, 7, 7].join(','))
        i += 1
      end
      expect(data.lines[i].chomp).to eq(['All Energy Sparks schools', 'All', 'All school types', 14, 14, 14, 14, 14].join(','))
    end
  end

  describe '.filename' do
    subject(:filename) { SchoolGroups::CsvGenerator.filename }

    it 'includes school-groups and time' do
      freeze_time do
        expect(filename).to eq "school-groups-#{Time.zone.now.iso8601.parameterize}.csv"
      end
    end
  end
end
