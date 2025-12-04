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

RSpec.shared_examples 'progress reports' do
  context 'when a target is set' do
    let(:progress_summary) { nil }
    let!(:school_target) { create(:school_target, school: school) }

    before do
      allow_any_instance_of(Targets::ProgressService).to receive(:progress_summary).and_return(progress_summary)
      visit school_path(school, switch: true)
    end

    it 'does not display prompt' do
      expect(page).not_to have_content("Set targets to reduce your school's energy consumption")
    end

    context 'and there is no data' do
      it 'has no notice' do
        expect(page).not_to have_content('Well done, you are making progress towards achieving your target')
        expect(page).not_to have_content('Unfortunately you are not meeting your targets')
      end
    end

    context 'and is being met' do
      let(:progress_summary) { build(:progress_summary, school_target: school_target) }

      it 'displays a notice' do
        expect(page).to have_content('Well done, you are making progress towards achieving your target')
      end

      it 'links to target page' do
        expect(page).to have_link('Review progress', href: school_school_targets_path(school))
      end
    end

    context 'and gas is not being met' do
      let(:progress_summary) { build(:progress_summary_with_failed_target, school_target: school_target) }

      it 'displays a notice' do
        expect(page).to have_content('Unfortunately you are not meeting your target to reduce your gas usage')
        expect(page).to have_content('Well done, you are making progress towards achieving your target to reduce your electricity and storage heater usage')
      end

      it 'links to target page' do
        expect(page).to have_link('Review progress', href: school_school_targets_path(school))
      end
    end

    context 'with expired target' do
      let!(:school_target)    { create(:school_target, school: school, start_date: 1.year.ago, target_date: Date.yesterday) }
      let(:progress_summary)  { build(:progress_summary, school_target: school_target) }

      it 'does not display a progress notice' do
        expect(page).not_to have_content('Well done, you are making progress towards achieving your target')
      end
    end

    context 'with lagging data' do
      let(:electricity_progress) { build(:fuel_progress, recent_data: false)}
      let(:progress_summary) { build(:progress_summary, electricity: electricity_progress, school_target: school_target) }

      it 'displays a notice' do
        expect(page).not_to have_content('Unfortunately you are not meeting your target')
        expect(page).to have_content('Well done, you are making progress towards achieving your target to reduce your gas and storage heater usage')
      end

      it 'links to target page' do
        expect(page).to have_link('Review progress', href: school_school_targets_path(school))
      end
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
    it_behaves_like 'progress reports' do
      let(:test_school) { school }
    end
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    it_behaves_like 'target prompts' do
      let(:test_school) { school }
    end
    it_behaves_like 'progress reports' do
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

      it_behaves_like 'progress reports' do
        let(:test_school) { school }
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
    it_behaves_like 'progress reports' do
      let(:test_school) { school }
    end
  end
end
