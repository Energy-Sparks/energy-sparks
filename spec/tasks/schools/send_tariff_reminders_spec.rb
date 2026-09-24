# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'schools:send_tariff_reminders' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'
  include EmailHelpers
  include ActiveJob::TestHelper

  let!(:organisation) { create(:school_admin).school }
  let(:tariff) { nil }

  before do
    tariff
    stub_env(SEND_AUTOMATED_EMAILS: true)
    task.invoke
    perform_enqueued_jobs
  end

  shared_examples 'it sends the expected email' do
    it 'sends the expected email' do
      expect(last_email.subject).to eq(I18n.t('energy_tariffs_mailer.reminder.subject', name: organisation.name))
      expect(last_email.text_part.decoded).to include('To help Energy Sparks to provide')
    end
  end

  shared_examples 'it sends reminders correctly' do
    context 'with no tariff' do
      it_behaves_like 'it sends the expected email'
    end

    context 'when tariff has expired' do
      let(:tariff) { create(:energy_tariff, tariff_holder: organisation) }

      it_behaves_like 'it sends the expected email'
    end

    context 'with a tariff set a year ago with no end date' do
      let(:tariff) do
        create(:energy_tariff, tariff_holder: organisation, start_date: 1.year.ago - 1.day, end_date: nil)
      end

      it_behaves_like 'it sends the expected email'
    end

    context 'with a current tariff' do
      let(:tariff) { create(:energy_tariff, tariff_holder: organisation, start_date: 1.day.ago, end_date: nil) }

      it_behaves_like 'no email is sent'
    end
  end

  context 'with a school' do
    it_behaves_like 'it sends reminders correctly'
  end

  context 'with a school group' do
    let(:organisation) { create(:group_admin).school_group }

    it_behaves_like 'it sends reminders correctly'
  end
end
