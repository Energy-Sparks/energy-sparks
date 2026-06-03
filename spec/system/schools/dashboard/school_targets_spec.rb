require 'rails_helper'

RSpec.shared_examples 'target prompts' do
  context 'when no target is set' do
    let(:feature_active)    { true }
    let(:enough_data)       { true }
    let(:enable_for_school) { true }

    before do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(feature_active)
      allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(enough_data)
      test_school.update!(enable_targets_feature: enable_for_school)
      visit school_path(test_school, switch: true)
    end

    it 'displays prompt' do
      expect(page).to have_content("Set targets to reduce your school's energy consumption")
      expect(page).to have_link('Set energy saving target')
    end

    context 'and not enough data' do
      let(:enough_data) { false }

      it 'doesnt display prompt' do
        expect(page).not_to have_content("Set targets to reduce your school's energy consumption")
      end
    end

    context 'and feature disabled for school' do
      let(:enable_for_school) { false }

      it 'doesnt display prompt' do
        expect(page).not_to have_content("Set targets to reduce your school's energy consumption")
      end
    end
  end

  context 'when target is expired' do
    let(:feature_active)    { true }
    let(:enough_data)       { true }
    let(:enable_for_school) { true }

    let!(:school_target)    { create(:school_target, school: school, start_date: 1.year.ago, target_date: Date.yesterday) }

    before do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(feature_active)
      allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(enough_data)
      test_school.update!(enable_targets_feature: enable_for_school)
      visit school_path(test_school, switch: true)
    end

    it 'prompts to set a new target' do
      expect(page).to have_link('Review progress', href: school_school_targets_path(school))
      expect(page).to have_content("It's time to review your progress and set a new target for the year ahead")
    end
  end
end

RSpec.describe 'adult dashboard target prompts', type: :system do
  let(:school) { create(:school) }

  before do
    sign_in(user) if user.present?
  end

  context 'as staff' do
    let(:user) { create(:staff, school: school) }

    it_behaves_like 'target prompts' do
      let(:test_school) { school }
    end
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    it_behaves_like 'target prompts' do
      let(:test_school) { school }
    end
  end

  %i[pupil student].each do |role|
    context "as #{role}" do
      let(:user) { create(role, school: school) }

      context 'when no target is set' do
        before do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
          allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
          visit school_path(school, switch: true)
        end

        it 'does not display target prompt' do
          expect(page).not_to have_content("Set targets to reduce your school's energy consumption")
          expect(page).not_to have_link('Set energy saving target')
        end
      end
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }

    it_behaves_like 'target prompts' do
      let(:test_school) { school }
    end
  end
end
