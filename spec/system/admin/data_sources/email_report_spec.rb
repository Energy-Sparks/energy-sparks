# frozen_string_literal: true

require 'rails_helper'

describe 'Data Sources Report Email', :include_application_helper, :school_groups do
  include ActiveJob::TestHelper
  include EmailHelpers

  let!(:data_source) { create(:data_source) }
  let!(:meter) { create(:electricity_meter, data_source:) }
  let!(:inactive_meter) { create(:electricity_meter, data_source:, active: false) }

  before do
    sign_in(create(:admin))
    visit admin_data_source_path(data_source)
  end

  it { expect(page).to have_text('Only active meters') }
  it { expect(page).to have_text('Active and inactive meters') }

  def submit
    all('button', text: 'Email Data Source Report').last.click
    perform_enqueued_jobs
  end

  def email = last_email.text_part.body.decoded

  context 'with active only' do
    before { submit }

    it { expect(email).to include(meter.mpan_mprn.to_s) }
    it { expect(email).not_to include(inactive_meter.mpan_mprn.to_s) }
  end

  context 'with all' do
    before do
      choose 'Active and inactive meters'
      submit
    end

    it { expect(email).to include(meter.mpan_mprn.to_s) }
    it { expect(email).to include(inactive_meter.mpan_mprn.to_s) }
  end
end
