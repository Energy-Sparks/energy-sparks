require 'rails_helper'

describe SchoolFilter do
  let(:school_group_a)      { create(:school_group) }
  let(:school_group_b)      { create(:school_group) }
  let(:scoreboard_a)        { create(:scoreboard) }
  let(:scoreboard_b)        { create(:scoreboard) }
  let!(:school_1) do
    create(:school, school_group: school_group_a, scoreboard: scoreboard_a)
  end
  let!(:school_2) do
    create(:school, school_group: school_group_b, scoreboard: scoreboard_b, school_type: :secondary)
  end
  let!(:school_3_invisible) do
    create(:school, school_group: school_group_b, scoreboard: scoreboard_a, visible: false)
  end
  let!(:school_no_data)           { create(:school, school_group: school_group_a, process_data: false) }
  let!(:school_not_data_enabled)  { create(:school, school_group: school_group_a, data_enabled: false) }

  it 'returns all process data, data enabled schools by default' do
    expect(SchoolFilter.new.filter).to contain_exactly(school_1, school_2)
  end

  it 'filters by school group' do
    expect(SchoolFilter.new(school_group_ids: [school_group_a.id]).filter).to eq [school_1]
    expect(SchoolFilter.new(school_group_ids: [school_group_a.id,
                                               school_group_b.id]).filter).to contain_exactly(school_1, school_2)
    expect(SchoolFilter.new(school_group_ids: [school_group_b.id]).filter).to eq [school_2]
  end

  it 'filters by scoreboard' do
    expect(SchoolFilter.new(scoreboard_ids: [scoreboard_b.id]).filter).to eq [school_2]
    expect(SchoolFilter.new(scoreboard_ids: [scoreboard_a.id,
                                             scoreboard_b.id]).filter).to contain_exactly(school_1, school_2)
  end

  it 'filters by school types' do
    expect(SchoolFilter.new(school_types: [School.school_types[:primary]]).filter).to eq [school_1]
    expect(SchoolFilter.new(school_types: [School.school_types[:secondary]]).filter).to eq [school_2]
    expect(SchoolFilter.new(school_types: [School.school_types[:primary],
                                           School.school_types[:secondary]]).filter).to contain_exactly(school_1,
                                                                                                        school_2)
  end

  it 'filters by school type' do
    expect(SchoolFilter.new(school_type: School.school_types[:primary]).filter).to eq [school_1]
    expect(SchoolFilter.new(school_type: School.school_types[:secondary]).filter).to eq [school_2]
    expect(SchoolFilter.new(school_type: School.school_types[:primary],
                            school_types: [School.school_types[:primary],
                                           School.school_types[:secondary]]).filter).to contain_exactly(school_1)
  end

  it 'filters by country' do
    school_1.update(country: :scotland)
    expect(SchoolFilter.new(country: School.countries[:scotland]).filter).to eq [school_1]
    expect(SchoolFilter.new(country: School.countries[:wales]).filter).to eq []
  end

  it 'filters by visible' do
    expect(SchoolFilter.new(include_invisible: true).filter).to contain_exactly(school_1, school_2, school_3_invisible)
  end

  it 'filters by scoreboard and group' do
    expect(SchoolFilter.new(include_invisible: true, scoreboard_ids: [scoreboard_a],
                            school_group_ids: [school_group_b.id]).filter).to eq [school_3_invisible]
  end

  context 'when filtering by Funder' do
    let(:funder_1)            { create(:funder) }
    let(:funder_2)            { create(:funder) }

    before do
      create(:commercial_licence, school: school_1, contract: create(:commercial_contract, contract_holder: funder_1))
    end

    it 'filters by funder' do
      expect(SchoolFilter.new(funder: funder_1.id).filter).to eq [school_1]
      expect(SchoolFilter.new(funder: funder_2.id).filter).to eq []
    end
  end
end
