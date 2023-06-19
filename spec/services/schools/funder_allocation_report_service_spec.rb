require 'rails_helper'

RSpec.describe Schools::FunderAllocationReportService, type: :service do

  let(:service) { Schools::FunderAllocationReportService.new }

  describe '.csv_filename' do
    let(:frozen_time) { Time.zone.today }
    before { Timecop.freeze(frozen_time) }
    after { Timecop.return }

    it 'generates expected name' do
      expect(service.csv_filename).to eq("funder-allocation-report-#{frozen_time.iso8601}.csv")
    end
  end

  describe '.csv' do

    let!(:academic_year_start) { Date.today - 6.months }
    let!(:academic_year_end) { Date.today + 6.months }
    let!(:academic_year) { create(:academic_year,
      start_date: academic_year_start, end_date: academic_year_end) }
    let!(:calendar) { create(:calendar, academic_years: [academic_year]) }

    let(:local_authority_area)  { create(:local_authority_area) }

    let(:school_onboarding) { create(:school_onboarding, :with_events,
      event_names: [:onboarding_complete, :onboarding_data_enabled]) }

    let(:school_group)  { create(:school_group) }

    let!(:school_1)  { create(:school,
      visible: true,
      school_onboarding: school_onboarding,
      school_group: school_group,
      calendar: calendar,
      country: :england,
      region: :east_of_england,
      local_authority_area: local_authority_area,
      percentage_free_school_meals: 50)
    }

    let!(:activities)  { create_list(:activity, 5, school: school_1) }
    let!(:actions)     { create_list(:observation, 3, :intervention, school: school_1) }

    #only basic data, helps to catch errors checking for nils
    let!(:school_2)  { create(:school, visible: true, school_group: create(:school_group)) }
    #not included in export
    let!(:not_visible)  { create(:school, visible: false, school_group: school_group) }

    let(:csv)   { service.csv }

    it 'returns rights headers' do
      expect(csv.lines.first.chomp).to eq Schools::FunderAllocationReportService.csv_headers.join(",")
    end

    it 'returns one row per visible school' do
      expect(csv.lines.count).to eq 3
    end

    it 'returns expected data for school' do
      expect(csv.lines[1].chomp).to eq [
          school_1.school_group.name,
          school_1.name,
          'Primary',
          'true',
          school_1.school_onboarding.onboarding_completed_on.iso8601,
          school_1.school_onboarding.first_made_data_enabled.iso8601,
          school_1.funding_status.humanize,
          'ab1 2cd',
          'England',
          school_1.number_of_pupils,
          school_1.percentage_free_school_meals,
          school_1.local_authority_area.name,
          school_1.region.humanize,
          5, #todo activites
          3, #todo actions
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
        ].join(",")
    end
  end
end
