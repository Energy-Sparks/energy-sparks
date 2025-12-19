require 'rails_helper'

RSpec.describe 'adult dashboard prompts', type: :system do
  before { SiteSettings.create!(audit_activities_bonus_points: 50) }

  let(:data_enabled)                    { true }
  let(:confirmed_at)                    { 1.day.ago }
  let(:school)                          { create(:school, :with_school_group, data_enabled: data_enabled) }
  let!(:school_group_dashboard_message) { school.school_group.create_dashboard_message(message: 'School group message') }
  let!(:school_dashboard_message)       { school.create_dashboard_message(message: 'School message') }
  let!(:programme)                      { }
  let!(:audit)                          { create(:audit, :with_todos, school: school) }

  before do
    sign_in(user) if user.present?
    visit school_path(school, switch: true) # don't redirect pupils to pupil dashboard
  end

  context 'as guest' do
    let(:user) { nil }

    it_behaves_like 'dashboard message prompts', displayed: true
    it_behaves_like 'a training prompt', displayed: false
    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a rich audit prompt', displayed: true
  end

  context 'as user from another school' do
    let(:school2) { create(:school) }
    let(:user)    { create(:staff, school: school2) }

    it_behaves_like 'dashboard message prompts', displayed: true
    it_behaves_like 'a training prompt', displayed: false
    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a rich audit prompt', displayed: true
  end

  %i[pupil student].each do |role|
    context "as a #{role}" do
      let(:user) { create(role, school: school, confirmed_at: confirmed_at) }

      it_behaves_like 'dashboard message prompts', displayed: true
      it_behaves_like 'a training prompt', displayed: true
      it_behaves_like 'a complete programme prompt', displayed: true
      it_behaves_like 'a rich audit prompt', displayed: true
    end
  end

  context 'as staff' do
    let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

    it_behaves_like 'dashboard message prompts', displayed: true
    it_behaves_like 'a training prompt', displayed: true
    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a rich audit prompt', displayed: true
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school, confirmed_at: confirmed_at) }

    it_behaves_like 'dashboard message prompts', displayed: true
    it_behaves_like 'a training prompt', displayed: true
    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a rich audit prompt', displayed: true
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group, data_enabled: data_enabled) }
    let(:user)          { create(:group_admin, school_group: school_group, school: school, confirmed_at: confirmed_at) }

    it_behaves_like 'dashboard message prompts', displayed: true
    it_behaves_like 'a training prompt', displayed: true
    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a rich audit prompt', displayed: true
  end

  context 'as admin' do
    let(:user) { create(:admin, confirmed_at: confirmed_at) }

    it_behaves_like 'dashboard message prompts', displayed: true
    it_behaves_like 'a training prompt', displayed: false
    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a rich audit prompt', displayed: true
  end

  ## Testing functionality rather than just if prompts appear or not
  context 'with working prompts' do
    let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

    describe 'training prompt' do
      context 'when school is data enabled' do
        let(:data_enabled) { true }

        context 'when user confirmed in the last 30 days' do
          let(:confirmed_at) { 2.days.ago }

          it_behaves_like 'a training prompt', displayed: true
        end

        context 'when user confirmed more than 30 days ago' do
          let(:confirmed_at) { 31.days.ago }

          it_behaves_like 'a training prompt', displayed: false
        end
      end

      context 'when school is not data enabled' do
        let(:data_enabled) { false }

        it_behaves_like 'a training prompt', displayed: false

        context 'when user confirmed more than 30 days ago' do
          let(:confirmed_at) { 31.days.ago }

          it_behaves_like 'a training prompt', displayed: false
        end

        context 'when user confirmed in the last 30 days' do
          let(:confirmed_at) { 2.days.ago }

          it_behaves_like 'a training prompt', displayed: false
        end
      end
    end
  end
end
