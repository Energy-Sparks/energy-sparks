require 'rails_helper'

describe ConfirmationReminder do
  let(:now) { Time.current }

  before do
    travel_to(now)
  end

  shared_examples 'it ignores sending emails' do
    it 'does not send at any time' do
      expect(User.count).to eq(1)
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
      travel_to(now + 7.days)
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
      travel_to(now + 29.days)
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
      travel_to(now + 30.days)
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
    end
  end

  shared_examples 'it correctly sends emails' do
    it 'sends first and last reminders' do
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
      travel_to(now + 7.days)
      expect { described_class.send }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq('Reminder: please confirm your account on Energy Sparks')
      expect(ActionMailer::Base.deliveries.last.to_s).to include('A user account was recently created')
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
      travel_to(now + 29.days)
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
      travel_to(now + 30.days)
      expect { described_class.send }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.last.subject).to \
        eq('Final reminder: please confirm your account on Energy Sparks')
      expect { described_class.send }.to(not_change { ActionMailer::Base.deliveries.count })
    end
  end

  context 'with group user' do
    context 'when not confirmed' do
      context 'when user has been sent confirmation' do
        let!(:user) { create(:group_admin, confirmed_at: nil, confirmation_token: 'token', confirmation_sent_at: now) }

        it_behaves_like 'it correctly sends emails'
      end
    end

    context 'when user is already confirmed' do
      let!(:user) { create(:group_admin, confirmed_at: now, confirmation_token: 'token', confirmation_sent_at: now) }

      it_behaves_like 'it ignores sending emails'
    end
  end

  context 'with adult school user' do
    context 'when not confirmed' do
      context 'when user has not yet received any email' do
        # mimic when users are created during onboarding as we confirm them at the end of the process
        let!(:user) { create(:school_admin, :skip_confirmed) }

        it_behaves_like 'it ignores sending emails'
      end

      context 'when user has been sent confirmation' do
        let!(:user) { create(:school_admin, confirmed_at: nil, confirmation_token: 'token', confirmation_sent_at: now) }

        it_behaves_like 'it correctly sends emails'
      end

      context 'when school is archived' do
        let!(:school) { create(:school, :archived) }
        let!(:user) { create(:school_admin, confirmed_at: nil, confirmation_token: 'token', confirmation_sent_at: now, school: school) }

        it_behaves_like 'it ignores sending emails'
      end

      context 'when school is deleted' do
        let!(:school) { create(:school, :deleted) }
        let!(:user) { create(:school_admin, confirmed_at: nil, confirmation_token: 'token', confirmation_sent_at: now, school: school) }

        it_behaves_like 'it ignores sending emails'
      end
    end

    context 'when user is confirmed' do
      let!(:user) { create(:school_admin, confirmed_at: now, confirmation_token: 'token', confirmation_sent_at: now) }

      it_behaves_like 'it ignores sending emails'
    end
  end

  # no email address, auto confirmed at creation
  context 'with pupil' do
    let!(:user) { create(:pupil, confirmed_at: now) }

    it_behaves_like 'it ignores sending emails'
  end


  # auto confirmed during onboarding users become school admins when school is created during onboarding
  context 'with onboarding_user' do
    let!(:user) { create(:onboarding_user, confirmed_at: now) }

    it_behaves_like 'it ignores sending emails'
  end
end
