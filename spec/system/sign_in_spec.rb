require 'rails_helper'

shared_examples 'a logged in user' do
  it 'is logged in' do
    expect(page).to have_link('Sign Out')
    expect(page).not_to have_link('Sign In')
  end
end

shared_examples 'a logged out user' do
  it 'is logged out' do
    expect(page).to have_link('Sign In')
    expect(page).not_to have_link('Sign Out')
  end
end

shared_examples 'a user with updated last_sign_in_at' do
  it { expect(user.reload.last_sign_in_at).not_to eq(saved_last_sign_in_at) }
end

shared_examples 'a user with unmodified last_sign_in_at' do
  it { expect(user.reload.last_sign_in_at).to eq(saved_last_sign_in_at) }
end

shared_examples 'a user without a last_sign_in_at' do
  it { expect(user.reload.last_sign_in_at).to be_nil }
end

RSpec.describe 'sign in', type: :system do
  let!(:school) { create(:school, :with_school_group) }

  before do
    visit root_path
    click_on 'Sign In'
  end

  it 'shows empty staff login form' do
    within('#staff') do
      expect(find_field('Email').text).to be_blank
      expect(find_field('Password').text).to be_blank
      expect(page).to have_unchecked_field('Stay signed in')
    end
  end

  context 'staff login' do
    let!(:user) { create(:staff) }
    let(:check_remember_me) {}
    let(:travel_forward) {}
    let(:password) {}
    let!(:last_sign_in_at) { user.last_sign_in_at } # should be nil

    before do
      within('#staff') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: password
        check 'Stay signed in' if check_remember_me
        click_on 'Sign in'
      end
    end

    it_behaves_like 'a user without a last_sign_in_at'

    context 'when disabled' do
      let!(:user) { create(:staff, active: false) }

      let(:password) { user.password }

      it_behaves_like 'a logged out user'
      it_behaves_like 'a user with unmodified last_sign_in_at' do
        let(:saved_last_sign_in_at) { last_sign_in_at }
      end
    end

    context 'with incorrect password' do
      let(:password) { 'incorrectpassword' }

      it_behaves_like 'a logged out user'
      it_behaves_like 'a user with unmodified last_sign_in_at' do
        let(:saved_last_sign_in_at) { last_sign_in_at }
      end
    end

    context 'with correct password' do
      let(:password) { user.password }

      it_behaves_like 'a logged in user'
      it_behaves_like 'a user with updated last_sign_in_at' do
        let(:saved_last_sign_in_at) { last_sign_in_at }
      end

      context 'closing the browser and visiting home page' do
        let!(:saved_last_sign_in_at) { user.reload.last_sign_in_at }

        before do
          expire_cookies # kills session cookies
          travel_to(3.weeks.from_now) if travel_forward
          visit root_path
        end

        context 'with remember me checked' do
          let(:check_remember_me) { true }

          it_behaves_like 'a logged in user'
          it_behaves_like 'a user with updated last_sign_in_at'

          context 'and we have gone past the remember me expirey' do
            let(:travel_forward) { true }

            it_behaves_like 'a logged out user'
            it_behaves_like 'a user with unmodified last_sign_in_at'
          end
        end

        context 'with remember me unchecked' do
          let(:check_remember_me) { false }

          it_behaves_like 'a logged out user'
          it_behaves_like 'a user with unmodified last_sign_in_at'

          context 'and we have gone past the remember me expirey' do
            let(:travel_forward) { true }

            it_behaves_like 'a logged out user'
            it_behaves_like 'a user with unmodified last_sign_in_at'
          end
        end
      end
    end
  end

  it 'shows empty pupil login form' do
    within('#pupil') do
      expect(page).to have_select('Select your school', selected: [])
      expect(find_field('Your pupil password').text).to be_blank
    end
  end

  context 'pupil login' do
    let!(:user) { create(:pupil, school: school, pupil_password: 'correctpassword') }
    let!(:saved_last_sign_in_at) { user.last_sign_in_at }

    context 'in a school context' do
      before do
        visit pupils_school_path(school)
        click_on 'Log in with your pupil password'
        within '#pupil' do
          fill_in 'Your pupil password', with: password if password
          click_on 'Sign in'
        end
      end

      context 'with blank password' do
        let(:password) { '' }

        it { expect(page).to have_content('Please enter a password') }

        it_behaves_like 'a logged out user'
        it_behaves_like 'a user with unmodified last_sign_in_at'
      end

      context 'with incorrect password' do
        let(:password) { 'incorrectpassword' }

        it { expect(page).to have_content("Sorry, that password doesn't work") }

        it_behaves_like 'a logged out user'
        it_behaves_like 'a user with unmodified last_sign_in_at'
      end

      context 'with correct password' do
        let(:password) { 'correctpassword' }

        it { expect(page).to have_content('Signed in successfully') }
        it { expect(page).to have_current_path(pupils_school_path(school), ignore_query: true) }

        it_behaves_like 'a logged in user'
        it_behaves_like 'a user with updated last_sign_in_at'
      end
    end

    context 'non school context' do
      before do
        visit new_user_session_path(role: :pupil)
        within '#pupil' do
          select select_school, from: 'Select your school' if select_school
          fill_in 'Your pupil password', with: password
          click_on 'Sign in'
        end
      end

      context 'with school missing & correct password' do
        let(:select_school) { '' }
        let(:password) { 'correctpassword' }

        it { expect(page).to have_content('Please select a school') }

        it_behaves_like 'a user with unmodified last_sign_in_at'
        it_behaves_like 'a logged out user'
      end

      context 'with school present and incorrect password' do
        let(:select_school) { "#{school.name} (#{school.school_group.name})" }
        let(:password) { 'incorrectpassword' }

        it { expect(page).to have_content("Sorry, that password doesn't work") }

        it_behaves_like 'a user with unmodified last_sign_in_at'
        it_behaves_like 'a logged out user'
      end

      context 'with school present & correct password' do
        let(:select_school) { "#{school.name} (#{school.school_group.name})" }
        let(:password) { 'correctpassword' }

        it { expect(page).to have_content('Signed in successfully') }
        it { expect(page).to have_current_path(pupils_school_path(school), ignore_query: true) }

        it_behaves_like 'a logged in user'
        it_behaves_like 'a user with updated last_sign_in_at'
      end
    end
  end
end
