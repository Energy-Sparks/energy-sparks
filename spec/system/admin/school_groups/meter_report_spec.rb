# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Meter Report' do
  let(:school_group) { create(:school_group) }
  let(:user) { create(:admin) }

  before { sign_in user }

  shared_examples 'the meter report dialog' do
    it 'defaults to only active meters' do
      expect(page).to have_field('Only active meters', type: 'radio', checked: true)
      expect(page).to have_field('Active and inactive meters', type: 'radio', checked: false)
    end

    it 'queues a report containing only active meters by default' do
      expect { click_button 'Email Meter Report' }.to \
        have_enqueued_job(SchoolGroupMeterReportJob).with(to: user.email, school_group:, all_meters: false)
    end

    it 'queues a report including inactive meters when selected' do
      choose 'Active and inactive meters'
      expect { click_button 'Email Meter Report' }.to \
        have_enqueued_job(SchoolGroupMeterReportJob).with(to: user.email, school_group:, all_meters: true)
    end
  end

  context 'when on the school group page' do
    before { visit admin_school_group_path(school_group) }

    it_behaves_like 'the meter report dialog'

    it 'queues a meter data export' do
      click_button 'Meter data export'
      expect { click_button 'Email Meter Data Export' }.to \
        have_enqueued_mail(AdminMailer, :school_group_meter_data_export).with(school_group, user.email)
    end
  end

  context 'when on the school group meter report page' do
    before { visit admin_school_group_meter_report_path(school_group) }

    it_behaves_like 'the meter report dialog'
  end
end
