# frozen_string_literal: tru

require 'rails_helper'

describe 'onboarding report', :include_application_helper do
  let(:admin) { create(:admin) }

  let!(:onboarding) do
    create(
      :school_onboarding,
      :with_school,
      :with_events,
      event_names: [:email_sent, :onboarding_complete],
      contact_email: 'test@test.com',
    )
  end

  context 'when signed in as an admin' do
    before do
      sign_in(admin)
      visit admin_reports_path
      click_on 'Recently onboarded'
    end

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '#recently_onboarded_table' }
      let(:expected_header) do
        [
          ['Country', 'School group', 'School name', 'Contact email', 'Onboarding started', 'Onboarding completed', 'Data enabled?', 'Data enabled on', 'Days until enabled']
        ]
      end
      let(:expected_rows) do
        [
          [
            onboarding.school.country.presence&.capitalize,
            onboarding.school.school_group&.name.to_s,
            onboarding.school.name,
            onboarding.contact_email,
            nice_date_times(onboarding.started_on),
            nice_date_times(onboarding.completed_on),
            onboarding.school.data_enabled.to_s,
            onboarding.first_made_data_enabled.to_s,
            onboarding.days_until_data_enabled.to_s
          ]
        ]
      end
    end
  end
end
