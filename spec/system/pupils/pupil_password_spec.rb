require 'rails_helper'


describe 'pupil passwords' do

  let(:school_group){ create(:school_group, name: 'MySchoolGroup') }
  let(:school){ create(:school, name: 'MySchool', school_group: school_group) }
  let!(:pupil){ create(:pupil, pupil_password: 'theelectrons', school: school) }

  context "in a school context" do
    before do
      visit pupils_school_path(school)
      click_on "Log in with your pupil password"
      within '#pupil' do
        fill_in 'Your pupil password', with: password if password
        click_on 'Sign in'
      end
    end

    context "blank password" do
      let(:password) { "" }
      it { expect(page).to have_content('Please enter a password') }
    end

    context "incorrect password" do
      let(:password) { "theprotons" }
      it { expect(page).to have_content("Sorry, that password doesn't work") }
    end

    context "correct password" do
      let(:password) { "theelectrons" }
      it { expect(page).to have_content('Signed in successfully') }
      it { expect(page.current_path).to eq(pupils_school_path(school)) }
    end
  end

  context "non school context" do
    before do
      visit new_user_session_path(role: :pupil)
      within '#pupil' do
        select select_school, from: 'Select your school' if select_school
        fill_in 'Your pupil password', with: password
        click_on 'Sign in'
      end
    end

    context "school missing & correct password" do
      let(:select_school) { '' }
      let(:password) { 'theelectrons' }
      it { expect(page).to have_content('Please select a school') }
    end

    context "school present & correct password" do
      let(:select_school) { "MySchool (MySchoolGroup)" }
      let(:password) { 'theelectrons' }
      it { expect(page).to have_content('Signed in successfully') }
      it { expect(page.current_path).to eq(pupils_school_path(school)) }
    end

    context "school present and incorrect password" do
      let(:select_school) { "MySchool (MySchoolGroup)" }
      let(:password) { 'theprotons' }
      it { expect(page).to have_content("Sorry, that password doesn't work") }
    end
  end
end
