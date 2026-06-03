# frozen_string_literal: true

require 'rails_helper'

describe 'Engaged Schools Report', :aggregate_failures do
  include ActiveJob::TestHelper
  include EmailHelpers

  let(:admin) { create(:admin) }
  let!(:school) do
    travel_to(Time.zone.local(2025, 2, 4, 15, 30))
    create(:school, :with_school_group, :with_points,
           calendar: create(:calendar, :with_previous_and_next_academic_years))
  end
  let(:last_sign_in) { Time.zone.now }
  let(:email) { last_email }

  before do
    create(:school_admin, school: school, last_sign_in_at: last_sign_in)
    sign_in(admin)
    visit admin_reports_engaged_schools_path
  end

  def expected_rows(activities: 1)
    row = {
      'School Group': school.school_group.name,
      School: school.name,
      'School Type': 'Primary',
      Funder: '',
      Country: school.country.humanize,
      Active: 'Y',
      'Data Visible': 'Y',
      Admin: 'Admin',
      Activities: activities.to_s,
      Actions: '0',
      Programmes: '0',
      Target?: 'N',
      'Transport Survey?': 'N',
      Temperatures?: 'N',
      Audit?: 'N',
      'Active Users': '1',
      'Last Visit': last_sign_in.iso8601
    }
    [row.keys.join(','), row.values.join(',')]
  end

  context 'with all groups' do
    before { perform_enqueued_jobs { click_on 'Email Current Year' } }

    it_behaves_like 'it has a csv attachment' do
      let(:filename) { 'engaged-schools-report-2025-02-04T15-30-00Z.csv' }
      let(:data) { expected_rows }
    end

    it { expect(email.subject).to eq('Engaged schools report 2025-02-04T15:30:00Z') }
  end

  context 'when the previous year' do
    before { perform_enqueued_jobs { click_on 'Email Previous Year' } }

    it_behaves_like 'it has a csv attachment' do
      let(:filename) { 'engaged-schools-report-previous-year-2025-02-04T15-30-00Z.csv' }
      let(:data) { expected_rows(activities: 0) }
    end

    it { expect(email.subject).to eq('Engaged schools report (previous year) 2025-02-04T15:30:00Z') }
  end

  context 'when filtering by school group' do
    before do
      create(:school, :with_school_group, :with_points)
      select school.school_group.name, from: 'School Group'
      perform_enqueued_jobs { click_on 'Email Current Year' }
    end

    it_behaves_like 'it has a csv attachment' do
      let(:filename) { "engaged-schools-report-#{school.school_group.name.parameterize}-2025-02-04T15-30-00Z.csv" }
      let(:data) { expected_rows }
    end
    it { expect(email.subject).to eq("Engaged schools report for #{school.school_group.name} 2025-02-04T15:30:00Z") }
  end
end
