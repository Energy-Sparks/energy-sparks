require 'rails_helper'

RSpec.describe Onboarding::ReminderMailer, type: :service do
  let(:email_sent_less_than_a_week_ago)       { create(:school_onboarding_event, event: :email_sent, created_at: 6.days.ago) }
  let(:email_sent_over_a_week_ago)            { create(:school_onboarding_event, event: :email_sent, created_at: 8.days.ago) }
  let(:reminder_sent_less_than_a_week_ago)    { create(:school_onboarding_event, event: :reminder_sent, created_at: 6.days.ago) }
  let(:reminder_sent_over_a_week_ago)         { create(:school_onboarding_event, event: :reminder_sent, created_at: 8.days.ago) }

  let(:deliveries) { ActionMailer::Base.deliveries }

  it { expect(deliveries).to be_empty }

  describe ".deliver_due" do
    let!(:onboardings) { [] }
    let(:onboarding) { onboardings.first }

    before { Onboarding::ReminderMailer.deliver_due }

    context "email_sent over a week ago" do
      let(:onboardings) { [create(:school_onboarding, events: [email_sent_over_a_week_ago])] }

      before { onboarding.reload }

      it "sends email" do
        expect(deliveries.count).to be 1
      end

      it "creates reminder_sent event" do
        expect(onboarding.events.pluck(:event)).to match_array %w[email_sent reminder_sent]
      end
    end

    context "reminder_sent over a week ago" do
      let(:onboardings) { [create(:school_onboarding, events: [email_sent_over_a_week_ago, reminder_sent_over_a_week_ago])] }

      before { onboarding.reload }

      it "sends email" do
        expect(deliveries.count).to be 1
      end

      it "creates another reminder_sent event" do
        expect(onboarding.events.pluck(:event)).to match_array %w[email_sent reminder_sent reminder_sent]
      end
    end

    context "reminder_sent less than a week ago" do
      let(:onboardings) { [create(:school_onboarding, events: [email_sent_over_a_week_ago, reminder_sent_less_than_a_week_ago])] }

      before { onboarding.reload }

      it "doesn't send email" do
        expect(deliveries.count).to be 0
      end

      it "events remain the same" do
        expect(onboarding.events.pluck(:event)).to match_array %w[email_sent reminder_sent]
      end
    end

    context "email_sent over a week ago & reminder_sent less than a week ago" do
      let(:onboardings) { [create(:school_onboarding, events: [email_sent_over_a_week_ago, reminder_sent_over_a_week_ago, reminder_sent_less_than_a_week_ago])] }

      before { onboarding.reload }

      it "doesn't send email" do
        expect(deliveries.count).to be 0
      end

      it "events remain the same" do
        expect(onboarding.events.pluck(:event)).to match_array %w[email_sent reminder_sent reminder_sent]
      end
    end

    context "email_sent less than a week ago" do
      let(:onboardings) { [create(:school_onboarding, events: [email_sent_less_than_a_week_ago])] }

      before { onboarding.reload }

      it "doesn't send email" do
        expect(deliveries.count).to be 0
      end

      it "events remain the same" do
        expect(onboarding.events.pluck(:event)).to match_array ["email_sent"]
      end
    end
  end

  describe ".deliver" do
    let!(:onboardings) {[]}

    before { Onboarding::ReminderMailer.deliver(school_onboardings: onboardings) }

    context "two onboardings with the same contact email" do
      let(:onboardings) do
        [create(:school_onboarding, events: [], contact_email: 'test@test.com'),
         create(:school_onboarding, events: [], contact_email: 'test@test.com')]
      end

      it "sends one email" do
        expect(deliveries.count).to be 1
      end

      it "email has the plural subject" do
        expect(deliveries.last.subject).to eq("Don't forget to set up your schools on Energy Sparks")
      end

      it "creates another reminder_sent event for both onboardings" do
        expect(onboardings[0].reload.events.pluck(:event)).to match_array ["reminder_sent"]
        expect(onboardings[1].reload.events.pluck(:event)).to match_array ["reminder_sent"]
      end
    end

    context "two onboardings with different contact emails" do
      let(:onboardings) do
        [create(:school_onboarding, events: [], contact_email: 'email_a@test.com'),
         create(:school_onboarding, events: [], contact_email: 'email_b@test.com')]
      end

      it "sends seperate emails" do
        expect(deliveries.count).to be 2
      end

      it "emails have the singular subject" do
        deliveries.each do |email|
          expect(email.subject).to eq("Don't forget to set up your school on Energy Sparks")
        end
      end

      it "creates another reminder_sent event for both onboardings" do
        expect(onboardings[0].reload.events.pluck(:event)).to match_array ["reminder_sent"]
        expect(onboardings[1].reload.events.pluck(:event)).to match_array ["reminder_sent"]
      end
    end

    context "three onboardings, two with the same contact emails" do
      let(:onboardings) do
        [create(:school_onboarding, events: [], contact_email: 'email_a@test.com'),
         create(:school_onboarding, events: [], contact_email: 'email_b@test.com'),
         create(:school_onboarding, events: [], contact_email: 'email_a@test.com')]
      end

      it "sends two emails" do
        expect(deliveries.count).to be 2
      end

      it "creates a reminder_sent event for all onboardings" do
        expect(onboardings[0].reload.events.pluck(:event)).to match_array ["reminder_sent"]
        expect(onboardings[1].reload.events.pluck(:event)).to match_array ["reminder_sent"]
        expect(onboardings[2].reload.events.pluck(:event)).to match_array ["reminder_sent"]
      end
    end
  end
end
