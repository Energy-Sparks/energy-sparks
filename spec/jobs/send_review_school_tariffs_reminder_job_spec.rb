require 'rails_helper'

describe SendReviewSchoolTariffsReminderJob do
  let(:school) { create(:school) }
  let!(:school_admin) { create(:school_admin, school: school) }
  let!(:admin) { create(:admin) }
  let!(:staff) { create(:staff, school: school) }
  let!(:pupil) { create(:pupil, school: school) }

  let(:job) { SendReviewSchoolTariffsReminderJob.new }

  describe '#perform' do
    it 'sends an email to school admins to remind them to keep their tariff updated on a valid day of the year' do
      expect do
        job.perform
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("It’s time to review the energy tariffs for #{school.name} on Energy Sparks")
      expect(school.users.count).to eq(3)
      expect(ActionMailer::Base.deliveries.last.to).to eq([school_admin.email])
    end
  end
end
