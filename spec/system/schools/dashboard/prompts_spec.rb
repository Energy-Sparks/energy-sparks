require 'rails_helper'

shared_examples "a dashboard showing dashboard messages" do
  it { expect(page).to have_content("School group message") }
  it { expect(page).to have_content("School message") }
end

shared_examples "a dashboard not showing dashboard messages" do
  it { expect(page).not_to have_content("School group message") }
  it { expect(page).not_to have_content("School message") }
end

shared_examples "a dashboard showing training prompt" do
  it { expect(page).to have_content("New to Energy Sparks? Sign up to one of our upcoming free online training courses to help you get the most from the service.") }
end

shared_examples "a dashboard not showing training prompt" do
  it { expect(page).not_to have_content("New to Energy Sparks? Sign up to one of our upcoming free online training courses to help you get the most from the service.") }
end

shared_examples "a dashboard showing complete programme prompt" do
  it { expect(page).to have_content("You have completed 0/3 of the activities") }
end

shared_examples "a dashboard not showing complete programme prompt" do
  it { expect(page).not_to have_content("You have completed 0/3 of the activities") }
end

shared_examples "a dashboard training prompt" do
  context "school is data enabled" do
    let(:data_enabled) { true }

    context "and user confirmed in the last 30 days" do
      let(:confirmed_at) { 2.days.ago }

      it_behaves_like "a dashboard showing training prompt"
    end

    context "and user confirmed more than 30 days ago" do
      let(:confirmed_at) { 31.days.ago }

      it_behaves_like "a dashboard not showing training prompt"
    end
  end

  context "school is not data enabled" do
    let(:data_enabled) { false }

    it_behaves_like "a dashboard not showing training prompt"
    context "and user confirmed more than 30 days ago" do
      let(:confirmed_at) { 31.days.ago }

      it_behaves_like "a dashboard not showing training prompt"
    end

    context "and user confirmed in the last 30 days" do
      let(:confirmed_at) { 2.days.ago }

      it_behaves_like "a dashboard not showing training prompt"
    end
  end
end

########### TESTS START HERE ###########

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

      it_behaves_like "a dashboard not showing dashboard messages"
      it_behaves_like "a dashboard not showing training prompt"
      it_behaves_like "a dashboard not showing complete programme prompt"
    end

    context 'as user from another school' do
      let(:school2) { create(:school) }
      let(:user)    { create(:staff, school: school2) }

      it_behaves_like "a dashboard not showing dashboard messages"
      it_behaves_like "a dashboard not showing training prompt"
      it_behaves_like "a dashboard not showing complete programme prompt"
    end

    context 'as pupil' do
      let(:user) { create(:pupil, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard showing dashboard messages"
      it_behaves_like "a dashboard showing training prompt"
      it_behaves_like "a dashboard showing complete programme prompt"
    end

    context 'as staff' do
      let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard showing dashboard messages"
      it_behaves_like "a dashboard showing training prompt"
      it_behaves_like "a dashboard showing complete programme prompt"
    end

    context 'as school admin' do
      let(:user) { create(:school_admin, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard showing dashboard messages"
      it_behaves_like "a dashboard showing training prompt"
      it_behaves_like "a dashboard showing complete programme prompt"
    end

    context 'as group admin' do
      let(:school_group)  { create(:school_group) }
      let(:school)        { create(:school, school_group: school_group, data_enabled: data_enabled) }
      let(:user)          { create(:group_admin, school_group: school_group, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard showing dashboard messages"
      it_behaves_like "a dashboard showing training prompt"
      it_behaves_like "a dashboard showing complete programme prompt"
    end

    context 'as admin' do
      let(:user) { create(:admin, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard showing dashboard messages"
      it_behaves_like "a dashboard showing training prompt"
      it_behaves_like "a dashboard showing complete programme prompt"
    end
  end

  ### context to be removed when activities_2023 feature tidied up ###
  context "with activities_2023 feature flag switched off" do
    let(:activities_2023_feature) { false }

    context 'as pupil' do
      let(:user) { create(:pupil, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard not showing complete programme prompt"
    end

    context 'as staff' do
      let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard not showing complete programme prompt"
    end

    context 'as school admin' do
      let(:user) { create(:school_admin, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard not showing complete programme prompt"
    end

    context 'as group admin' do
      let(:school_group)  { create(:school_group) }
      let(:school)        { create(:school, school_group: school_group, data_enabled: data_enabled) }
      let(:user)          { create(:group_admin, school_group: school_group, school: school, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard not showing complete programme prompt"
    end

    context 'as admin' do
      let(:user) { create(:admin, confirmed_at: confirmed_at) }

      it_behaves_like "a dashboard not showing complete programme prompt"
    end
  end
end
