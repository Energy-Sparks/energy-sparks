require 'rails_helper'

RSpec.describe "pupil dashboard prompts", type: :system do
  let(:confirmed_at)                    { 1.day.ago }
  let(:school)                          { create(:school, :with_school_group, data_enabled: true) }
  let(:activities_2023_feature)         { false }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: activities_2023_feature.to_s do
      example.run
    end
  end

  before do
    sign_in(user) if user.present?
    visit pupils_school_path(school)
  end

  context "with activities_2023 feature flag switched on" do
    let(:activities_2023_feature) { true }

    context 'when user is a guest' do
      let(:user) { nil }

      pending do
        it_behaves_like "a complete programme prompt", displayed: false
        it_behaves_like "a recommendations scoreboard prompt", displayed: false
      end
    end

    context 'when user is from another school' do
      let(:school2) { create(:school) }
      let(:user)    { create(:staff, school: school2) }

      pending do
        it_behaves_like "a complete programme prompt", displayed: false
        it_behaves_like "a recommendations scoreboard prompt", displayed: false
      end
    end

    context 'when user is a pupil' do
      let(:user) { create(:pupil, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations scoreboard prompt", displayed: true
    end

    context 'when user is staff' do
      let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations scoreboard prompt", displayed: true
    end

    context 'when user is a school admin' do
      let(:user) { create(:school_admin, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations scoreboard prompt", displayed: true
    end

    context 'when user is a group admin' do
      let(:school_group)  { create(:school_group) }
      let(:school)        { create(:school, school_group: school_group, data_enabled: true) }
      let(:user)          { create(:group_admin, school_group: school_group, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations scoreboard prompt", displayed: true
    end

    context 'when user is an admin' do
      let(:user) { create(:admin, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations scoreboard prompt", displayed: true
    end
  end
end
