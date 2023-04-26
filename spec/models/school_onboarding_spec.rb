require 'rails_helper'

describe SchoolOnboarding, type: :model do
  context 'knows when it has only done an email send and or reminder email' do
    it 'with an email sent' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent]
      expect(onboarding.has_only_sent_email_or_reminder?).to be true
    end

    it 'with an email and a reminder sent' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent, :reminder_sent]
      expect(onboarding.has_only_sent_email_or_reminder?).to be true
    end

    it 'or when it has not with extra events' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent, :reminder_sent, :school_admin_created]
      expect(onboarding.has_only_sent_email_or_reminder?).to be false
    end

    it 'knows when it is complete' do
      onboarding = create :school_onboarding, :with_events, event_names: [:onboarding_complete]
      expect(onboarding.incomplete?).to be false
      expect(onboarding.complete?).to be true
    end

    it 'knows when it is ready for review' do
      onboarding = create :school_onboarding, :with_events, event_names: [:pupil_account_created]
      expect(onboarding.incomplete?).to be true
      expect(onboarding.complete?).to be false
      expect(onboarding.ready_for_review?).to be true
    end

    it 'knows when it is incomplete' do
      onboarding = create :school_onboarding
      expect(onboarding.incomplete?).to be true
      expect(onboarding.complete?).to be false
    end
  end

  describe ".email_locales" do
    it "only en for england" do
      expect(SchoolOnboarding.new(country: 'england').email_locales).to eq([:en])
    end
    it "only en for scotland" do
      expect(SchoolOnboarding.new(country: 'scotland').email_locales).to eq([:en])
    end
    it "en and cy for wales" do
      expect(SchoolOnboarding.new(country: 'wales').email_locales).to eq([:en, :cy])
    end
  end

  describe ".incomplete" do
    context "when there is an onboarding with no events" do
      let!(:incomplete) { create :school_onboarding }
      it "returns onboarding" do
        expect(SchoolOnboarding.incomplete).to eq([incomplete])
      end
    end
    context "when an onboarding has events" do
      let!(:complete) { create :school_onboarding, :with_events, event_names: [:onboarding_complete] }
      let!(:incomplete) { create :school_onboarding, :with_events, event_names: [:email_sent] }
      it "returns all incomplete onboardings only" do
        expect(SchoolOnboarding.incomplete).to eq([incomplete])
      end
      context "scoped to school group" do
        let(:school_group) { create :school_group }
        let!(:group_complete) { create :school_onboarding, :with_events, event_names: [:onboarding_complete], school_group: school_group }
        let!(:group_incomplete) { create :school_onboarding, :with_events, event_names: [:email_sent], school_group: school_group }
        it "returns incomplete onboardings scoped to group only" do
          expect(school_group.school_onboardings.incomplete).to eq([group_incomplete])
        end
        it "returns all incomplete onboardings" do
          expect(SchoolOnboarding.incomplete).to eq([incomplete, group_incomplete])
        end
      end
    end
  end
end
