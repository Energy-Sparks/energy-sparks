require 'rails_helper'

RSpec.shared_examples "dashboard prompts" do
  before(:each) do
    visit school_path(test_school, switch: true)
  end

  it 'has school group dashboard message' do
    expect(page).to have_content("School group message")
  end
end

RSpec.describe "adult dashboard prompts", type: :system do
  let(:school)             { create(:school, :with_school_group) }
  let!(:dashboard_message) { school.school_group.create_dashboard_message(message: "School group message") }

  before(:each) do
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user)                { nil }
    before(:each) do
      visit school_path(school)
    end

    it 'does not display school group dashboard message' do
      expect(page).to_not have_content("School group message")
    end
  end

  context 'as user from another school' do
    let(:school2) { create(:school) }
    let(:user)    { create(:staff, school: school2) }
    before(:each) do
      visit school_path(school)
    end

    it 'does not display school group dashboard message' do
      expect(page).to_not have_content("School group message")
    end
  end

  context 'as pupil' do
    let(:user)          { create(:pupil, school: school) }
    include_examples "dashboard prompts" do
      let(:test_school) { school }
    end
  end

  context 'as staff' do
    let(:user)   { create(:staff, school: school) }
    include_examples "dashboard prompts" do
      let(:test_school) { school }
    end
  end

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }
    include_examples "dashboard prompts" do
      let(:test_school) { school }
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group, school: school) }
    include_examples "dashboard prompts" do
      let(:test_school) { school }
    end
  end

  context 'as admin' do
    let(:user)  { create(:admin) }
    include_examples "dashboard prompts" do
      let(:test_school) { school }
    end
  end
end
