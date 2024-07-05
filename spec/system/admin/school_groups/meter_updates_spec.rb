# frozen_string_literal: true

require 'rails_helper'

describe 'bulk updating procurement routes and data sources' do
  let!(:admin) { create(:admin) }
  let!(:data_sources) do
    %i[electricity gas solar_pv].index_with { |type| DataSource.create(name: "#{type.to_s.titleize} data source") }
  end
  let!(:procurement_routes) do
    %i[electricity gas solar_pv].index_with do |type|
      ProcurementRoute.create(organisation_name: "#{type.to_s.titleize} procurement route")
    end
  end
  let(:school) { create(:school, :with_school_group, active: false) }
  let(:other_school) { create(:school, :with_school_group, active: false) }
  let!(:meters) do
    { electricity: [create(:electricity_meter, school: school), create(:electricity_meter, school: other_school)],
      gas: [create(:gas_meter, school: school), create(:gas_meter, school: other_school)],
      solar_pv: [create(:solar_pv_meter, school: school), create(:solar_pv_meter, school: other_school)] }
  end

  before do
    sign_in(create(:admin))
    visit admin_school_group_path(school.school_group)
    click_on 'Meter updates'
  end

  context 'with data source' do
    def meters_data_sources(meters)
      meters.map { |meter| meter.reload.data_source }
    end

    it 'updates the correct electricity data source' do
      select(data_sources[:electricity].name, from: 'Bulk update data source for all electricity meters')
      click_on 'Update electricity data source for all schools in this group'
      expect(school.school_group.reload.default_data_source_electricity).to eq(data_sources[:electricity])
      expect(meters_data_sources(meters[:electricity])).to contain_exactly(data_sources[:electricity], nil)
    end

    it 'updates the correct gas data source' do
      select(data_sources[:gas].name, from: 'Bulk update data source for all gas meters')
      click_on 'Update gas data source for all schools in this group'
      expect(meters_data_sources(meters[:gas])).to contain_exactly(data_sources[:gas], nil)
    end

    it 'updates the correct solar pv data source' do
      select(data_sources[:solar_pv].name, from: 'Bulk update data source for all solar pv meters')
      click_on 'Update solar pv data source for all schools in this group'
      expect(meters_data_sources(meters[:solar_pv])).to contain_exactly(data_sources[:solar_pv], nil)
    end

    it 'updates from default' do
      school.school_group.update(default_data_source_electricity: data_sources[:electricity])
      refresh
      click_on 'Update electricity data source for all schools in this group'
      expect(meters_data_sources(meters[:electricity])).to contain_exactly(data_sources[:electricity], nil)
    end

    it 'updates to none' do
      school.school_group.update(default_data_source_electricity: data_sources[:electricity])
      meters[:electricity].first.update(data_source: data_sources[:electricity])

      select('none', from: 'Bulk update data source for all electricity meters')
      click_on 'Update electricity data source for all schools in this group'
      expect(school.school_group.reload.default_data_source_electricity).to be_nil
      expect(meters_data_sources(meters[:electricity])).to contain_exactly(nil, nil)
    end
  end

  context 'with procurement route' do
    def meters_procurement_routes(meters)
      meters.map { |meter| meter.reload.procurement_route }
    end

    it 'updates the correct electricity procurement route' do
      select(procurement_routes[:electricity].organisation_name,
             from: 'Bulk update procurement route for all electricity meters')
      click_on 'Update electricity procurement route for all schools in this group'
      expect(school.school_group.reload.default_procurement_route_electricity).to eq(procurement_routes[:electricity])
      expect(meters_procurement_routes(meters[:electricity])).to contain_exactly(procurement_routes[:electricity], nil)
    end

    it 'updates the correct gas procurement route' do
      select(procurement_routes[:gas].organisation_name, from: 'Bulk update procurement route for all gas meters')
      click_on 'Update gas procurement route for all schools in this group'
      expect(meters_procurement_routes(meters[:gas])).to contain_exactly(procurement_routes[:gas], nil)
    end

    it 'updates the correct solar pv procurement route' do
      select(procurement_routes[:solar_pv].organisation_name,
             from: 'Bulk update procurement route for all solar pv meters')
      click_on 'Update solar pv procurement route for all schools in this group'
      expect(meters_procurement_routes(meters[:solar_pv])).to contain_exactly(procurement_routes[:solar_pv], nil)
    end
  end
end
