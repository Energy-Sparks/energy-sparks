require 'rails_helper'

describe SchoolFilter do

  let(:school_group_a)  { create(:school_group) }
  let(:school_group_b)  { create(:school_group) }
  let!(:school_1)       { create(:school, school_group: school_group_a) }
  let!(:school_2)       { create(:school, school_group: school_group_b) }
  let!(:school_no_data) { create(:school, school_group: school_group_a, process_data: false) }

  it 'returns all process data schools by default' do
    expect(SchoolFilter.new.filter).to eq [school_1, school_2]
  end

  it 'filters by school group' do
    expect(SchoolFilter.new(school_group_ids: [school_group_a.id]).filter).to eq [school_1]
    expect(SchoolFilter.new(school_group_ids: [school_group_a.id, school_group_b.id]).filter).to eq [school_1, school_2]
    expect(SchoolFilter.new(school_group_ids: [school_group_b.id]).filter).to eq [school_2]
  end

  it 'filters by fuel type' do
    school_1.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_gas: true))

    expect(school_1.has_gas?).to be true
    expect(school_2.has_gas?).to be false

    expect(SchoolFilter.new(fuel_type: :gas).filter).to eq [school_1]
  end

  it 'filters by combination' do
    school_1.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_gas: true, has_electricity: false))
    school_2.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_gas: false, has_electricity: true))

    expect(school_1.has_gas?).to be true
    expect(school_2.has_gas?).to be false
    expect(school_2.has_electricity?).to be true

    expect(SchoolFilter.new(fuel_type: :gas, school_group_ids: [school_group_a.id]).filter).to eq [school_1]
    expect(SchoolFilter.new(fuel_type: :gas, school_group_ids: [school_group_b.id]).filter).to eq []

    expect(SchoolFilter.new(fuel_type: :electricity, school_group_ids: [school_group_a.id]).filter).to eq []
    expect(SchoolFilter.new(fuel_type: :electricity, school_group_ids: [school_group_b.id]).filter).to eq [school_2]
  end
end
