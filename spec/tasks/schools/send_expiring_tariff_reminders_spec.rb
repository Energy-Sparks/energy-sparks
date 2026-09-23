# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'schools:send_expiring_tariff_reminders' do # rubocop:disable RSpec/DescribeClass
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
      expect(last_email.text_part.decoded).to include('Thank you for updating')
    end
  end

  shared_examples 'it sends reminders correctly' do
    context 'when tariff is expiring in 30 days' do
      let(:tariff) { create(:energy_tariff, tariff_holder: organisation, end_date: 30.days.from_now) }

      it_behaves_like 'it sends the expected email'

      context 'and another tariff after' do
        let(:tariff) do
          super()
          create(:energy_tariff, tariff_holder: organisation, start_date: 30.days.from_now, end_date: nil)
        end

        it_behaves_like 'it sends no email'
      end

      context 'and another tariff after with a different meter type' do
        let(:tariff) do
          super()
          create(:energy_tariff, tariff_holder: organisation, start_date: 30.days.from_now, end_date: nil,
                                 meter_type: :gas)
        end

        it_behaves_like 'it sends the expected email'
      end

      context 'with another tariff expiring' do
        let(:tariff) do
          super()
          create(:energy_tariff, tariff_holder: organisation, end_date: 30.days.from_now)
        end

        it_behaves_like 'it sends the expected email'
      end
    end

    context 'when tariff is expiring in 29 days' do
      let(:tariff) { create(:energy_tariff, tariff_holder: organisation, end_date: 29.days.from_now) }

      it_behaves_like 'it sends no email'
    end

    context 'with a tariff set a year ago with no end date' do
      let(:tariff) { create(:energy_tariff, tariff_holder: organisation, start_date: 1.year.ago - 1.day, end_date: nil) }

      it_behaves_like 'it sends no email'
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
