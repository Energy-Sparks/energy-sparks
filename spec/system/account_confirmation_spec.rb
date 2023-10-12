require 'rails_helper'

describe 'account confirmation' do
  let(:school) { create :school }

  it 'requires my account is confirmed before I can log in' do
    teacher = create :staff, confirmed_at: nil, email: 'unconfirmed@test.com', school: school

    open_email 'unconfirmed@test.com'

    current_email.click_link 'Confirm my account'

    fill_in 'New password', with: 'testtest1'
    fill_in 'Confirm new password', with: 'testtest1'

    click_on 'Complete registration'

    expect(page).to have_content('Sign Out')

    teacher.reload
    expect(teacher.confirmed?).to eq(true)
  end
end
