require 'rails_helper'

RSpec.describe "adult dashboard prompts", type: :system do
  let(:data_enabled)                    { true }
  let(:confirmed_at)                    { 1.day.ago }
  let(:school)                          { create(:school, :with_school_group, data_enabled: data_enabled) }
  let!(:school_group_dashboard_message) { school.school_group.create_dashboard_message(message: "School group message") }
  let!(:school_dashboard_message)       { school.create_dashboard_message(message: "School message") }

  let(:programme_type) { create(:programme_type_with_activity_types) }
  let!(:programme) { create(:programme, programme_type: programme_type, started_on: '2020-01-01', school: school) }

  let(:activities_2023_feature) { false }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: activities_2023_feature.to_s do
      example.run
    end
  end

  before do
    sign_in(user) if user.present?
    visit school_path(school, switch: true) # don't redirect pupils to pupil dashboard
  end

  context "with activities_2023 feature flag switched on" do
    let(:activities_2023_feature) { true }

    context 'as guest' do
      let(:user) { nil }

      it_behaves_like "dashboard message prompts", displayed: false
      it_behaves_like "a training prompt", displayed: false
      it_behaves_like "a complete programme prompt", displayed: false
      it_behaves_like "a recommendations prompt", displayed: false
    end

    context 'as user from another school' do
      let(:school2) { create(:school) }
      let(:user)    { create(:staff, school: school2) }

      it_behaves_like "dashboard message prompts", displayed: false
      it_behaves_like "a training prompt", displayed: false
      it_behaves_like "a complete programme prompt", displayed: false
      it_behaves_like "a recommendations prompt", displayed: false
    end

    context 'as pupil' do
      let(:user) { create(:pupil, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "dashboard message prompts", displayed: true
      it_behaves_like "a training prompt", displayed: true
      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations prompt", displayed: true
    end

    context 'as staff' do
      let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "dashboard message prompts", displayed: true
      it_behaves_like "a training prompt", displayed: true
      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations prompt", displayed: true
    end

    context 'as school admin' do
      let(:user) { create(:school_admin, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "dashboard message prompts", displayed: true
      it_behaves_like "a training prompt", displayed: true
      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations prompt", displayed: true
    end

    context 'as group admin' do
      let(:school_group)  { create(:school_group) }
      let(:school)        { create(:school, school_group: school_group, data_enabled: data_enabled) }
      let(:user)          { create(:group_admin, school_group: school_group, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "dashboard message prompts", displayed: true
      it_behaves_like "a training prompt", displayed: true
      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations prompt", displayed: true
    end

    context 'as admin' do
      let(:user) { create(:admin, confirmed_at: confirmed_at) }

      it_behaves_like "dashboard message prompts", displayed: true
      it_behaves_like "a training prompt", displayed: true
      it_behaves_like "a complete programme prompt", displayed: true
      it_behaves_like "a recommendations prompt", displayed: true
    end
  end

  ### context to be removed when activities_2023 feature tidied up ###
  context "with activities_2023 feature flag switched off" do
    let(:activities_2023_feature) { false }

    context 'as pupil' do
      let(:user) { create(:pupil, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: false
      it_behaves_like "a recommendations prompt", displayed: false
    end

    context 'as staff' do
      let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: false
      it_behaves_like "a recommendations prompt", displayed: false
    end

    context 'as school admin' do
      let(:user) { create(:school_admin, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: false
      it_behaves_like "a recommendations prompt", displayed: false
    end

    context 'as group admin' do
      let(:school_group)  { create(:school_group) }
      let(:school)        { create(:school, school_group: school_group, data_enabled: data_enabled) }
      let(:user)          { create(:group_admin, school_group: school_group, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: false
      it_behaves_like "a recommendations prompt", displayed: false
    end

    context 'as admin' do
      let(:user) { create(:admin, confirmed_at: confirmed_at) }

      it_behaves_like "a complete programme prompt", displayed: false
      it_behaves_like "a recommendations prompt", displayed: false
    end
  end

  ## Testing functionality rather than just if they appear or not
  context "with working prompts" do
    let(:activities_2023_feature) { true }
    let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

    it_behaves_like "a functional training prompt"
  end
end
