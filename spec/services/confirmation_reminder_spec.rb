require 'rails_helper'

describe ConfirmationReminder do
  let(:now) { Time.current }

  before do
    travel_to(now)
    create(:user, confirmed_at: nil, confirmation_token: 'token', confirmation_sent_at: now)
  end

  it 'sends first and final reminder' do
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
