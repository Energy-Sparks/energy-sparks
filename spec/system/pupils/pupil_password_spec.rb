require 'rails_helper'


describe 'pupil passwords' do

  let(:school){ create(:school) }
  let!(:pupil){ create(:pupil, pupil_password: 'theelectrons', school: school) }

  it 'allows the pupil to log in just using the pupil password' do
    visit school_path(school)
    click_on "Log in with your pupil password"

    click_on 'Sign in'
    expect(page).to have_content('Please enter a password')

    fill_in 'Password', with: 'theprotons'
    click_on 'Sign in'
    expect(page).to have_content("Sorry, that password doesn't work")

    fill_in 'Password', with: 'theelectrons'
    click_on 'Sign in'

    expect(page).to have_content('Signed in successfully')
    expect(page.current_path).to eq(pupils_school_path(school))

  end

end
