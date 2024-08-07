require 'rails_helper'

describe SendReviewGroupTariffsReminderJob do
  subject(:job) { SendReviewGroupTariffsReminderJob.new }

  let!(:school_group) { create(:school_group) }
  let!(:school_group_admin) { create(:group_admin, school_group: school_group) }

  describe '#priority' do
    it_behaves_like 'a high priority job'
  end

  describe '#perform' do
    it 'sends an email to school admins to remind them to keep their tariff updated on a valid day of the year' do
      expect do
        job.perform
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("It's time to review the energy tariffs for #{school_group.name} on Energy Sparks")
      expect(ActionMailer::Base.deliveries.last.to).to eq([school_group_admin.email])
    end
  end
end
