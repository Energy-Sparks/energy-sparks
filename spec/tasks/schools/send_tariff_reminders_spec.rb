# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'schools:send_tariff_reminders' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'
  include EmailHelpers
  include ActiveJob::TestHelper

  before { stub_const('ENV', ENV.to_h.merge('SEND_AUTOMATED_EMAILS' => 'true')) }

  context 'with no tariff' do
    it 'sends the expected email' do
      school = create(:school_admin).school
      # create(:school)
      task.invoke
      perform_enqueued_jobs
      expect(last_email.subject).to eq(I18n.t('energy_tariffs_mailer.reminder.subject', name: school.name))
    end
  end

  # context 'when tariff has expired' do
  # end

  # context 'with a tariff set a year ago with no end date' do
  # end

  context 'with a tariff' do
    it "doesn't send an email" do
      school = create(:school_admin).school
      # create(:school)
      task.invoke
      perform_enqueued_jobs
      expect(last_email.subject).to eq(I18n.t('energy_tariffs_mailer.reminder.subject', name: school.name))
    end
  end
  
  context 'with a tariff already set after the current one' do

  end

end
