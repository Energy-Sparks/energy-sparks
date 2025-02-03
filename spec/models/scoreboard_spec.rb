require 'rails_helper'

describe Scoreboard, :scoreboards, type: :model do
  subject!(:scoreboard) { create(:scoreboard) }

  describe 'abilities' do
    let(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'public scoreboard' do
      context 'guests' do
        it { expect(ability).to be_able_to(:read, scoreboard) }
      end

      context 'admin' do
        let(:user) { create(:admin) }

        it { expect(ability).to be_able_to(:read, scoreboard) }
      end
    end

    context 'private scoreboard' do
      subject!(:scoreboard) { create :scoreboard, public: false }

      context 'guests' do
        it { expect(ability).not_to be_able_to(:read, scoreboard) }
      end

      context 'admin' do
        let(:user) { create(:admin) }

        it { expect(ability).to be_able_to(:read, scoreboard) }
      end

      context 'school_admin' do
        let!(:school)       { create(:school, :with_school_group, scoreboard: scoreboard) }
        let!(:user)         { create(:school_admin, school: school)}

        it { expect(ability).to be_able_to(:read, scoreboard) }
      end

      context 'staff' do
        let!(:school)       { create(:school, :with_school_group, scoreboard: scoreboard) }
        let!(:user)         { create(:staff, school: school)}

        it { expect(ability).to be_able_to(:read, scoreboard) }
      end
    end
  end

  describe '#safe_destroy' do
    it 'does not let you delete if there is an associated school' do
      create(:school, scoreboard: scoreboard)
      expect do
        subject.safe_destroy
      end.to raise_error(
        EnergySparks::SafeDestroyError, 'Scoreboard has associated schools'
      ).and(not_change { Scoreboard.count })
    end

    it 'lets you delete if there are no schools' do
      expect do
        subject.safe_destroy
      end.to change(Scoreboard, :count).from(1).to(0)
    end
  end

  context 'as a Scorable' do
    subject!(:scoreboard) { create :scoreboard, academic_year_calendar: template_calendar }

    let!(:template_calendar) { create :template_calendar, :with_previous_and_next_academic_years }
    let(:school_group) { nil }

    it_behaves_like 'a scorable'
  end

  describe 'MailchimpUpdateable' do
    subject { create(:scoreboard) }

    it_behaves_like 'a MailchimpUpdateable' do
      let(:mailchimp_field_changes) do
        {
          name_en: 'Renamed scoreboard',
        }
      end
    end
  end
end
