require 'rails_helper'

describe SchoolFilter do

  let(:school_group_a)      { create(:school_group) }
  let(:school_group_b)      { create(:school_group) }
  let(:scoreboard_a)        { create(:scoreboard) }
  let(:scoreboard_b)        { create(:scoreboard) }
  let!(:school_1)                 { create(:school, school_group: school_group_a, scoreboard: scoreboard_a) }
  let!(:school_2)                 { create(:school, school_group: school_group_b, scoreboard: scoreboard_b) }
  let!(:school_3_invisible)       { create(:school, school_group: school_group_b, scoreboard: scoreboard_a, visible: false) }
  let!(:school_no_data)           { create(:school, school_group: school_group_a, process_data: false) }
  let!(:school_not_data_enabled)  { create(:school, school_group: school_group_a, data_enabled: false) }

  it 'returns all process data, data enabled schools by default' do
    expect(SchoolFilter.new.filter).to match_array [school_1, school_2]
  end

  it 'filters by school group' do
    expect(SchoolFilter.new(school_group_ids: [school_group_a.id]).filter).to eq [school_1]
    expect(SchoolFilter.new(school_group_ids: [school_group_a.id, school_group_b.id]).filter).to match_array [school_1, school_2]
    expect(SchoolFilter.new(school_group_ids: [school_group_b.id]).filter).to eq [school_2]
  end

  it 'filters by scoreboard' do
    expect(SchoolFilter.new(scoreboard_ids: [scoreboard_b.id]).filter).to eq [school_2]
    expect(SchoolFilter.new(scoreboard_ids: [scoreboard_a.id, scoreboard_b.id]).filter).to match_array [school_1, school_2]
  end

  it 'filters by visible' do
    expect(SchoolFilter.new(include_invisible: true).filter).to match_array [school_1, school_2, school_3_invisible]
  end

  it 'filters by scoreboard and group' do
    expect(SchoolFilter.new(include_invisible: true, scoreboard_ids: [scoreboard_a], school_group_ids: [school_group_b.id]).filter).to eq [school_3_invisible]
  end
end
