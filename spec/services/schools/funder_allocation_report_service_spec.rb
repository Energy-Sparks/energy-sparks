# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::FunderAllocationReportService, type: :service do
  let(:service) { described_class.new }

  describe '.csv_filename' do
    let(:frozen_time) { Time.zone.today }

    before { travel_to(frozen_time) }

    it 'generates expected name' do
      expect(service.csv_filename).to eq("funder-allocation-report-#{frozen_time.iso8601}.csv")
    end
  end

  describe '.csv' do
    let!(:academic_year_start) { Time.zone.today - 6.months }
    let!(:academic_year_end) { Time.zone.today + 6.months }
    let!(:academic_year) do
      create(:academic_year,
             start_date: academic_year_start, end_date: academic_year_end)
    end
    let!(:calendar) { create(:calendar, academic_years: [academic_year]) }

    let(:local_authority_area) { create(:local_authority_area) }

    let(:school_onboarding) do
      create(:school_onboarding, :with_events,
             event_names: %i[onboarding_complete onboarding_data_enabled])
    end

    let(:data_source_1) { create(:data_source) }
    let(:procurement_route_1) { create(:procurement_route) }

    let(:data_source_2) { create(:data_source) }
    let(:procurement_route_2) { create(:procurement_route) }

    let(:data_source_3) { create(:data_source) }
    let(:procurement_route_3) { create(:procurement_route) }

    let!(:funder) { Funder.create(name: 'Funder 1') }
    let!(:funder_2) { Funder.create(name: 'Funder 2') }

    let(:school_group) { create(:school_group) }

    let!(:school_1) do
      school = create(:school,
                      visible: true,
                      school_onboarding: school_onboarding,
                      school_group: school_group,
                      calendar: calendar,
                      country: :england,
                      region: :east_of_england,
                      diocese: create(:school_group, :diocese),
                      local_authority_area_group: create(:school_group, :local_authority_area),
                      local_authority_area: local_authority_area,
                      percentage_free_school_meals: 50,
                      funder: funder,
                      removal_date: nil)
      school.project_groups << create(:school_group, :project)
      create(:staff, school:)
      school
    end

    let!(:activities)  { create_list(:activity, 5, school: school_1) }
    let!(:actions)     { create_list(:observation, 3, :intervention, school: school_1) }

    let!(:electricity_meter) do
      create(:electricity_meter, active: true, data_source: data_source_1, procurement_route: procurement_route_1,
                                 school: school_1)
    end
    let!(:gas_meter) do
      create(:gas_meter, active: true, data_source: data_source_2, procurement_route: procurement_route_2,
                         school: school_1)
    end
    let!(:solar_meter) do
      create(:solar_pv_meter, active: true, data_source: data_source_3, procurement_route: procurement_route_3,
                              school: school_1)
    end

    # only basic data, helps to catch errors checking for nils
    let!(:school_2) do
      create(:school, visible: true, active: false, removal_date: nil, archived_date: Time.zone.today,
                      school_group: create(:school_group), funder: funder_2)
    end
    # not included in export
    let!(:not_visible) do
      create(:school, visible: true, active: false, removal_date: Time.zone.today, school_group: school_group)
    end

    let(:csv)   { service.csv }

    it 'returns the right headers' do
      expect(csv.lines.first.chomp).to eq described_class.csv_headers.join(',')
    end

    it 'returns one row per visible school' do
      expect(csv.lines.count).to eq 3
    end

    it 'returns expected data for school' do
      expect(school_1.archived?).to be(false)
      expect(school_2.archived?).to be(true)

      expect(csv.lines[1].chomp).to eq [
        school_1.school_group.name,
        school_1.name,
        'Primary',
        'false',
        'true',
        school_1.school_onboarding.onboarding_completed_on.iso8601,
        school_1.school_onboarding.first_made_data_enabled.iso8601,
        funder.name,
        school_1.funding_status.humanize,
        'AB1 2CD',
        'England',
        school_1.number_of_pupils,
        school_1.percentage_free_school_meals,
        1,
        school_1.local_authority_area_group.name,
        school_1.region.humanize,
        school_1.diocese.name,
        school_1.project_groups.map(&:name).join('|'),
        5,
        3,
        electricity_meter.data_source.name,
        nil,
        nil,
        electricity_meter.procurement_route.organisation_name,
        nil,
        nil,
        gas_meter.data_source.name,
        nil,
        nil,
        gas_meter.procurement_route.organisation_name,
        nil,
        nil,
        solar_meter.data_source.name,
        nil,
        nil,
        solar_meter.procurement_route.organisation_name,
        nil,
        nil
      ].join(',')
      expect(csv.lines[2].chomp).to eq [
        school_2.school_group.name,
        school_2.name,
        'Primary',
        'true',
        'true',
        nil,
        nil,
        school_2.funder.name,
        school_2.funding_status.humanize,
        'AB1 2CD',
        'England',
        school_2.number_of_pupils,
        nil,
        0,
        nil,
        nil,
        nil,
        nil,
        0,
        0,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil
      ].join(',')
    end
  end
end
