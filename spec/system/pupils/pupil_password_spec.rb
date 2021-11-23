require 'rails_helper'


describe 'pupil passwords' do

  let(:school){ create(:school) }
  let!(:pupil){ create(:pupil, pupil_password: 'theelectrons', school: school) }

  it 'allows the pupil to log in just using the pupil password' do
    visit pupils_school_path(school)
    click_on "Log in with your pupil password"

    # blank password
    within '#pupil' do
      click_on 'Sign in'
    end
    expect(page).to have_content('Please enter a password')

    # incorrect password
    fill_in 'Your pupil password', with: 'theprotons'
    within '#pupil' do
      click_on 'Sign in'
    end
    expect(page).to have_content("Sorry, that password doesn't work")

    fill_in 'Your pupil password', with: 'theelectrons'
    within '#pupil' do
      click_on 'Sign in'
    end

    expect(page).to have_content('Signed in successfully')
    expect(page.current_path).to eq(pupils_school_path(school))
  end

  it 'allows the pupil to select their school' do
    visit new_user_session_path(role: :pupil)

    select school.name, from: 'Select your school'
    fill_in 'Your pupil password', with: 'theelectrons'
    within '#pupil' do
      click_on 'Sign in'
    end

    expect(page).to have_content('Signed in successfully')
    expect(page.current_path).to eq(pupils_school_path(school))
  end

end
