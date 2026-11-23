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
    let(:calendar) do
      academic_year = create(:academic_year,
                             start_date: Time.zone.today - 6.months, end_date: Time.zone.today + 6.months)
      create(:calendar, academic_years: [academic_year])
    end
    let(:school_group) { create(:school_group) }
    let!(:school) do
      school_onboarding = create(:school_onboarding, :with_events,
                                 event_names: %i[onboarding_complete onboarding_data_enabled])
      school = create(:school,
                      visible: true,
                      data_sharing: :within_group,
                      school_onboarding: school_onboarding,
                      school_group:,
                      calendar:,
                      country: :england,
                      region: :east_of_england,
                      diocese: create(:school_group, :diocese),
                      local_authority_area_group: create(:school_group, :local_authority_area),
                      local_authority_area: create(:local_authority_area),
                      percentage_free_school_meals: 50,
                      removal_date: nil)
      school.project_groups << create(:school_group, :project)
      school.organisation_group = school_group
      contract = create(:commercial_contract, contract_holder: school_group)
      create(:commercial_licence, contract:, school:)
      create(:staff, school:)

      # for future funding summary
      calendar = create(:national_calendar, title: 'England and Wales')
      academic_year = create(:academic_year, calendar:)
      create(:commercial_licence, contract:, school:)
      next_academic_year = create(:academic_year,
                                  calendar:,
                                  start_date: academic_year.end_date + 1.day,
                                  end_date: academic_year.end_date + 12.months)
      create(:commercial_licence,
             contract:, school:,
             status: :confirmed,
             start_date: next_academic_year.start_date,
             end_date: next_academic_year.end_date)

      school
    end

    let!(:electricity_meter) do
      create(:electricity_meter, active: true, data_source: create(:data_source),
                                 procurement_route: create(:procurement_route), school: school)
    end
    let!(:gas_meter) do
      create(:gas_meter, active: true, data_source: create(:data_source),
                         procurement_route: create(:procurement_route), school: school)
    end
    let!(:solar_meter) do
      create(:solar_pv_meter, active: true, data_source: create(:data_source),
                              procurement_route: create(:procurement_route), school: school)
    end

    # only basic data, helps to catch errors checking for nils
    let!(:archived_school) do
      create(:school, visible: true, active: false, removal_date: nil, archived_date: Time.zone.today,
                      school_group: create(:school_group))
    end
    let(:csv) { service.csv }

    before do
      create(:funder, name: 'Funder 1')
      create_list(:activity, 5, school:)
      create_list(:observation, 3, :intervention, school:)
      # Removed schools are not included in the export.
      create(:school, visible: true, active: false, removal_date: Time.zone.today, school_group:)
    end

    it 'returns the right headers' do
      expect(csv.lines.first.chomp).to eq described_class.csv_headers.join(',')
    end

    it 'returns one row per visible school' do
      expect(csv.lines.count).to eq 3
    end

    it 'returns expected data for school' do
      expect(school.archived?).to be(false)
      expect(archived_school.archived?).to be(true)

      current_licence = school.licences.current.by_start_date.first

      expect(csv.lines[1].chomp).to eq [
        school.school_group.name,
        school.name,
        school.urn,
        'Primary',
        'false',
        'true',
        school.data_sharing.humanize,
        school.school_onboarding.onboarding_completed_on.iso8601,
        school.school_onboarding.first_made_data_enabled.iso8601,
        'MAT funding',
        'MAT funding',
        school.funding_status.humanize,
        'AB1 2CD',
        'England',
        school.number_of_pupils,
        school.percentage_free_school_meals,
        1,
        school.local_authority_area_group.name,
        school.region.humanize,
        school.diocese.name,
        school.project_groups.map(&:name).join('|'),
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
        nil,
        current_licence.contract.contract_holder.name,
        current_licence.contract.start_date,
        current_licence.contract.end_date,
        current_licence.status.humanize,
        current_licence.start_date,
        current_licence.end_date,
        current_licence.contract.product.name
      ].join(',')
      expect(csv.lines[2].chomp).to eq [
        archived_school.school_group.name,
        archived_school.name,
        archived_school.urn,
        'Primary',
        'true',
        'true',
        archived_school.data_sharing.humanize,
        nil,
        nil,
        nil,
        nil,
        archived_school.funding_status.humanize,
        'AB1 2CD',
        'England',
        archived_school.number_of_pupils,
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
        nil,
        nil, # Current Contract Holder
        nil,
        nil,
        nil, # Current Contract Status
        nil,
        nil,
        nil
      ].join(',')
    end

    it 'returns the current contract status' do
      school.licences.current.each { |licence| licence.update!(status: :invoiced) }

      rows = CSV.parse(csv, headers: true)
      row = rows.find { |school_row| school_row['URN'] == school.urn.to_s }
      expect(row['Current Contract Status']).to eq('Invoiced')
    end
  end
end
