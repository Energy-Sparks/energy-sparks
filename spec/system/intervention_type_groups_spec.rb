require 'rails_helper'

RSpec.describe "intervention type groups", type: :system do
  let!(:intervention_type_1) { create(:intervention_type) }
  let!(:intervention_type_2) { create(:intervention_type) }

  let!(:activities_2023_feature) { false }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: activities_2023_feature.to_s do
      example.run
    end
  end

  context "with activities_2023 feature flag switched on" do
    let(:activities_2023_feature) { true }
    let(:user) { }

    before do
      sign_in(user) if user.present?
      visit intervention_type_groups_path
    end

    context "when user is not logged in" do
      it_behaves_like "a recommended prompt", displayed: false
    end

    context "when user is logged in" do
      context "without a school" do
        let(:school) { }
        let(:user) { create :admin, school: school }

        it_behaves_like "a recommended prompt", displayed: false
      end

      context "with a school" do
        let(:school) { create :school }
        let(:user) { create :pupil, school: school }

        it_behaves_like "a recommended prompt"
      end
    end
  end

  context "with activities_2023 feature flag switched off" do
    let(:activities_2023_feature) { false }

    context 'as not logged in user' do
      describe 'intervention type groups can be viewed' do
        before do
          visit intervention_type_groups_path
        end

        it 'not including recommended actions' do
          expect(page).not_to have_content('Recommended for your school')
        end
      end
    end

    context 'as logged in user' do
      let(:school)  { create(:school) }
      let(:user)    { create(:user, school: school) }

      describe 'intervention type groups can be viewed' do
        before do
          sign_in(user)
          visit intervention_type_groups_path
        end

        it 'shows recommended actions' do
          expect(page).to have_content('Recommended for your school')
          expect(page).to have_content(intervention_type_1.name)
          expect(page).to have_content(intervention_type_2.name)
        end

        it 'links to all suggestions' do
          click_on 'View all suggestions'
          expect(page).to have_content('A collection of 2 actions that are suggested for your school')
          expect(page).to have_content(intervention_type_1.name)
          expect(page).to have_content(intervention_type_2.name)
        end
      end
    end
  end
end
