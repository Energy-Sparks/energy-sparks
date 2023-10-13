require 'rails_helper'

RSpec.describe RecentActivitiesMailer do
  let(:activity_1)            { create(:activity, title: 'first activity') }
  let(:activity_2)            { create(:activity, title: 'second activity') }
  let(:intervention_type_1)   { create(:intervention_type, name: 'first action') }
  let(:intervention_type_2)   { create(:intervention_type, name: 'second action') }
  let(:observation_1)         { create(:observation, observation_type: :temperature, intervention_type: intervention_type_1) }
  let(:observation_2)         { create(:observation, observation_type: :temperature, intervention_type: intervention_type_2) }

  let(:activity_ids)          { [activity_1.id, activity_2.id] }
  let(:observation_ids)       { [observation_1.id, observation_2.id] }

  describe '#email' do
    it 'sends an email with activity and observation ids' do
      RecentActivitiesMailer.with(activity_ids: activity_ids, observation_ids: observation_ids).email.deliver_now
      expect(ActionMailer::Base.deliveries.count).to eql 1
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql "Recently recorded activities"
      expect(email.body.to_s).to include('first activity')
      expect(email.body.to_s).to include('second activity')
      expect(email.body.to_s).to include('first action')
      expect(email.body.to_s).to include('second action')
    end
  end
end
