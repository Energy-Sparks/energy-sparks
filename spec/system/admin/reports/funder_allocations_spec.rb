# frozen_string_literal: true

require 'rails_helper'

describe 'FunderAllocations' do
  include ActiveJob::TestHelper
  include EmailHelpers

  before do
    travel_to(Time.zone.local(2026, 7, 16, 15, 30))
    create(:school, :with_school_group)
    sign_in(create(:admin))
    visit admin_reports_funder_allocations_path
  end

  describe 'when sending the report' do
    subject(:email) { last_email }

    before { perform_enqueued_jobs { click_on 'Email funder report' } }

    it { expect(email.attachments.first.filename).to eq('funder-allocation-report-2026-07-16.csv') }
    it { expect(email.subject).to eq('[energy-sparks-unknown] Energy Sparks - Funder allocation report 2026-07-16') }
  end
end
