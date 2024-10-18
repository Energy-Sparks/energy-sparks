require 'rails_helper'

RSpec.describe 'pupil dashboard prompts', type: :system do
  let(:confirmed_at)                    { 1.day.ago }
  let!(:scoreboard)                     { }
  let(:school)                          { create(:school, :with_school_group, data_enabled: true, scoreboard: scoreboard) }
  let!(:school_with_points)             { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

  before do
    SiteSettings.create!(temperature_recording_months: (1..12).map(&:to_s), electricity_price: 1, solar_export_price: 1, gas_price: 1)
    create(:national_calendar, title: 'England and Wales') # required for podium to show national placing
    sign_in(user) if user.present?
    visit pupils_school_path(school)
  end

  context 'when user is a guest', pending: 'a discussion on current behaviour' do
    let(:user) { nil }

    it_behaves_like 'a complete programme prompt', displayed: false
    it_behaves_like 'a transport survey prompt', displayed: false
    it_behaves_like 'a temperature measuring prompt', displayed: false
  end

  context 'when user is from another school', pending: 'a discussion on current behaviour' do
    let(:school2) { create(:school) }
    let(:user)    { create(:staff, school: school2) }

    it_behaves_like 'a complete programme prompt', displayed: false
    it_behaves_like 'a transport survey prompt', displayed: false
    it_behaves_like 'a temperature measuring prompt', displayed: false
  end

  context 'when user is a pupil' do
    let(:user) { create(:pupil, school: school, confirmed_at: confirmed_at) }

    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a transport survey prompt', displayed: true
    it_behaves_like 'a temperature measuring prompt', displayed: true
  end

  context 'when user is staff' do
    let(:user) { create(:staff, school: school, confirmed_at: confirmed_at) }

    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a transport survey prompt', displayed: true
    it_behaves_like 'a temperature measuring prompt', displayed: true
  end

  context 'when user is a school admin' do
    let(:user) { create(:school_admin, school: school, confirmed_at: confirmed_at) }

    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a transport survey prompt', displayed: true
    it_behaves_like 'a temperature measuring prompt', displayed: true
  end

  context 'when user is a group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group, data_enabled: true) }
    let(:user)          { create(:group_admin, school_group: school_group, school: school, confirmed_at: confirmed_at) }

    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a transport survey prompt', displayed: true
    it_behaves_like 'a temperature measuring prompt', displayed: true
  end

  context 'when user is an admin' do
    let(:user) { create(:admin, confirmed_at: confirmed_at) }

    it_behaves_like 'a complete programme prompt', displayed: true
    it_behaves_like 'a transport survey prompt', displayed: true
    it_behaves_like 'a temperature measuring prompt', displayed: true
  end
end
