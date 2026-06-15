require 'rails_helper'

RSpec.describe RecentActivitiesMailer do
  let(:activity_1) do
    create(:activity, title: 'first activity', school: create(:school, :with_school_group))
  end
  let(:activity_2) do
    create(:activity, title: 'second activity', school: create(:school, :with_school_group))
  end
  let(:intervention_type_1)   { create(:intervention_type, name: 'first action') }
  let(:intervention_type_2)   { create(:intervention_type, name: 'second action') }
  let(:observation_1)         do
    create(:observation, :intervention, intervention_type: intervention_type_1,
                                        school: create(:school, :with_school_group))
  end
  let(:observation_2) do
    create(:observation, :intervention, intervention_type: intervention_type_2,
                                        school: create(:school, :with_school_group))
  end

  let(:activity_ids)          { [activity_1.id, activity_2.id] }
  let(:observation_ids)       { [observation_1.id, observation_2.id] }

  describe '#email' do
    it 'sends an email with activity and observation ids' do
      RecentActivitiesMailer.with(activity_ids: activity_ids, observation_ids: observation_ids).email.deliver_now
      expect(ActionMailer::Base.deliveries.count).to be 1
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql 'Recently recorded activities'
      expect(email.html_part.decoded).to include('first activity')
      expect(email.html_part.decoded).to include('second activity')
      expect(email.html_part.decoded).to include('first action')
      expect(email.html_part.decoded).to include('second action')
    end
  end
end
