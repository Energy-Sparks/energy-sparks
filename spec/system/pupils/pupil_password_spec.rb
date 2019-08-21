require 'rails_helper'


describe 'pupil passwords' do

  let(:school){ create(:school) }
  let!(:pupil){ create(:pupil, pupil_password: 'theelectrons', school: school) }

  it 'allows the pupil to log in just using the pupil password' do
    visit new_pupils_school_session_path(school)

    fill_in 'Password', with: 'theelectrons'
    click_on 'Sign in'

    expect(page).to have_content('Signed in successfully')
    expect(page.current_path).to eq(pupils_school_path(school))

  end

end
