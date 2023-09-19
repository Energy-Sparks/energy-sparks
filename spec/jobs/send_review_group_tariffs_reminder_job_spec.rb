require 'rails_helper'

describe SendReviewGroupTariffsReminderJob do
  let(:valid_send_dates) { SendReviewGroupTariffsReminderJob::SEND_ON_MONTH_DAYS.map { |send_on| Date.new(Time.zone.today.year, send_on[:month], send_on[:day]) } }
  let!(:school_group) { create(:school_group) }
  let!(:school_group_admin) { create(:group_admin, school_group: school_group) }
  let(:job) { SendReviewGroupTariffsReminderJob.new }

  describe '#perform' do
    it 'sends an email to school admins to remind them to keep their tariff updated on a valid day of the year' do
      valid_send_dates.each do |valid_send_date|
        travel_to valid_send_date do
          expect do
            job.perform
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(ActionMailer::Base.deliveries.last.subject).to eq("Provide your school’s energy tariffs to Energy Sparks")
          expect(ActionMailer::Base.deliveries.last.to).to eq([school_group_admin.email])
        end
      end
    end

    it 'does not send an email to school admins to remind them to keep their tariff updated on a invalid day of the year' do
      valid_send_dates.each do |valid_send_date|
        travel_to valid_send_date + 1.day do
          expect do
            job.perform
          end.not_to change { ActionMailer::Base.deliveries.count }
        end
      end
    end
  end
end
