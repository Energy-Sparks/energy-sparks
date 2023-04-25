require 'rails_helper'

RSpec.shared_examples "dashboard prompts" do
  before(:each) do
    visit school_path(test_school, switch: true)
  end

  it 'has prompt to view programmes' do
    expect(page).to have_content("Take the next step towards completing one of our short programmes of activity to increase your impact and score points for your school")
  end

  it 'has prompt to record activity' do
    expect(page).to have_content("Teach pupils about energy and climate change within the context of your own school by completing our freely available activities")
  end

  it 'has prompt to record an action' do
    expect(page).to have_content("Record energy saving actions made by school staff and facilities management to help to track whether your interventions have saved energy.")
  end

  it 'has prompt to start survey' do
    expect(page).to have_content("Start a transport survey so that you can find out how much carbon your school community generates by travelling to school")
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

    it 'does not have prompt to view programmes' do
      expect(page).to_not have_content("Take the next step towards completing one of our short programmes of activity to increase your impact and score points for your school")
    end

    it 'does not have prompt to record activity' do
      expect(page).to_not have_content("Teach pupils about energy and climate change within the context of your own school by completing our freely available activities")
    end

    it 'does not have prompt to record an action' do
      expect(page).to_not have_content("Record energy saving actions made by school staff and facilities management to help to track whether your interventions have saved energy.")
    end

    it 'does not have prompt to start survey' do
      expect(page).to_not have_content("Start a transport survey so that you can find out how much carbon your school community generates by travelling to school")
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

    it 'does not have prompt to view programmes' do
      expect(page).to_not have_content("Take the next step towards completing one of our short programmes of activity to increase your impact and score points for your school")
    end

    it 'does not have prompt to record activity' do
      expect(page).to_not have_content("Teach pupils about energy and climate change within the context of your own school by completing our freely available activities")
    end

    it 'does not have prompt to record an action' do
      expect(page).to_not have_content("Record energy saving actions made by school staff and facilities management to help to track whether your interventions have saved energy.")
    end

    it 'does not have prompt to start survey' do
      expect(page).to_not have_content("Start a transport survey so that you can find out how much carbon your school community generates by travelling to school")
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
