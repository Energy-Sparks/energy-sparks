# frozen_string_literal: true

require 'rails_helper'

describe 'Engaged Schools Report' do
  include ActiveJob::TestHelper

  let(:admin) { create(:admin) }
  let!(:school) do
    create(:school, :with_school_group, :with_points,
           calendar: create(:calendar, :with_previous_and_next_academic_years))
  end
  let(:last_sign_in)  { Time.zone.now }
  let!(:user)         { create(:school_admin, school: school, last_sign_in_at: last_sign_in) }

  before do
    sign_in(admin)
    visit admin_reports_engaged_schools_path
  end

  def expect_email_with_report(activities: 1)
    email = ActionMailer::Base.deliveries.last
    expect(email.attachments.first.body.decoded.split("\r\n").map { |line| line.split(',') }).to eq(
      [['School Group', 'School', 'Funder', 'Country', 'Active', 'Data Visible', 'Admin',
        'Activities', 'Actions', 'Programmes', 'Target?', 'Transport Survey?', 'Temperatures?', 'Audit?',
        'Active Users', 'Last Visit'],
       [school.school_group.name, school.name, '', school.country.humanize, 'Y', 'Y', '',
        activities.to_s, '0', '0', 'N', 'N', 'N', 'N',
        '1', last_sign_in.iso8601]]
    )
  end

  it 'all groups' do
    perform_enqueued_jobs { click_on 'Email Current Year' }
    expect_email_with_report
  end

  it 'previous year' do
    perform_enqueued_jobs { click_on 'Email Previous Year' }
    expect_email_with_report(activities: 0)
  end

  it 'filters school group' do
    create(:school, :with_school_group, :with_points)
    select school.school_group.name, from: 'School Group'
    perform_enqueued_jobs { click_on 'Email Current Year' }
    expect_email_with_report
  end
end
