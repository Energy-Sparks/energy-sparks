require 'rails_helper'

shared_examples "a logged in user" do
  it "is logged in" do
    expect(page).to have_link("Sign Out")
    expect(page).to_not have_link("Sign In")
  end
end

shared_examples "a logged out user" do
  it "is logged out" do
    expect(page).to have_link("Sign In")
    expect(page).to_not have_link("Sign Out")
  end
end

shared_examples "a user with updated trackable fields" do
  it { expect(user.reload.last_sign_in_at).to_not eq(last_sign_in_at) }
end

shared_examples "a user with unmodified trackable fields" do
  it { expect(user.reload.last_sign_in_at).to eq(last_sign_in_at) }
end

RSpec.describe "sign in", type: :system do
  let!(:school) { create(:school) }
  before do
    visit root_path
    click_on 'Sign In'
  end

  it "shows empty staff login form" do
    within('#staff') do
      expect(find_field('Email').text).to be_blank
      expect(find_field('Password').text).to be_blank
      expect(page).to have_unchecked_field('Stay signed in')
    end
  end

  context "staff login" do
    let!(:user) { create(:staff) }
    let(:check_remember_me) {}
    let(:travel_forward) {}

    before do
      within('#staff') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        check 'Stay signed in' if check_remember_me
        click_on 'Sign in'
      end
    end
    after(:each) { Timecop.return }

    context "closing the browser and visiting home page" do
      let!(:last_sign_in_at) { user.reload.last_sign_in_at }
      before do
        expire_cookies # kills session cookies
        Timecop.travel(3.weeks) if travel_forward
        visit root_path
      end

      context "with remember me checked" do
        let(:check_remember_me) { true }
        it_behaves_like "a logged in user"
        it_behaves_like "a user with updated trackable fields"

        context "and we have gone past the remember me expirey" do
          let(:travel_forward) { true }
          it_behaves_like "a logged out user"
          it_behaves_like "a user with unmodified trackable fields"
        end
      end

      context "with remember me unchecked" do
        let(:check_remember_me) { false }

        it_behaves_like "a logged out user"
        it_behaves_like "a user with unmodified trackable fields"

        context "and we have gone past the remember me expirey" do
          let(:travel_forward) { true }
          it_behaves_like "a logged out user"
          it_behaves_like "a user with unmodified trackable fields"
        end
      end
    end
  end

  it "shows empty pupil login form" do
    within('#pupil') do
      expect(page).to have_select('Select your school', selected: [])
      expect(find_field('Your pupil password').text).to be_blank
    end
  end

  context "pupil login" do
    let!(:user) { create(:pupil, school: school) }
    before do
      within('#pupil') do
        select user.school_name, from: 'Select your school'
        fill_in 'Your pupil password', with: user.pupil_password
        #### check 'Stay signed in' if check_remember_me
        click_on 'Sign in'
      end
    end
    it_behaves_like "a logged in user"
  end
end
