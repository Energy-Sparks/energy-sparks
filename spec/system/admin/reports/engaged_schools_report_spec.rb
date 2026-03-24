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
  let(:last_sign_in)  { Time.zone.now }
  let!(:user)         { create(:school_admin, school: school, last_sign_in_at: last_sign_in) }

  before do
    sign_in(admin)
    visit admin_reports_engaged_schools_path
  end

  def expected_row(activities)
    {
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
  end

  def expect_email_with_report(activities: 1)
    email = last_email
    row = expected_row(activities)
    expect(csv_attachment(email).csv).to eq([row.keys.join(','), row.values.join(',')])
    email
  end

  it 'all groups' do
    perform_enqueued_jobs { click_on 'Email Current Year' }
    email = expect_email_with_report
    expect(email.subject).to eq('Engaged schools report 2025-02-04T15:30:00Z')
    expect(email.attachments.first.filename).to eq('engaged-schools-report-2025-02-04T15-30-00Z.csv')
  end

  it 'previous year' do
    perform_enqueued_jobs { click_on 'Email Previous Year' }
    email = expect_email_with_report(activities: 0)
    expect(email.subject).to eq('Engaged schools report (previous year) 2025-02-04T15:30:00Z')
    expect(email.attachments.first.filename).to eq('engaged-schools-report-previous-year-2025-02-04T15-30-00Z.csv')
  end

  it 'filters school group' do
    create(:school, :with_school_group, :with_points)
    select school.school_group.name, from: 'School Group'
    perform_enqueued_jobs { click_on 'Email Current Year' }
    email = expect_email_with_report
    expect(email.subject).to eq("Engaged schools report for #{school.school_group.name} 2025-02-04T15:30:00Z")
    expect(email.attachments.first.filename).to \
      eq("engaged-schools-report-#{school.school_group.name.parameterize}-2025-02-04T15-30-00Z.csv")
  end
end
