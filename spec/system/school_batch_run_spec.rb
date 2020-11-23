require 'rails_helper'

RSpec.describe "school batch run", type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:admin, school: school)}
  let!(:school_batch_run) { create(:school_batch_run, school: school) }

  before(:each) do
    school_batch_run.info('analysing..')
    school_batch_run.error('bogus..')
    sign_in(user)
    visit school_path(school)
  end

  it 'should show school batch runs' do
    click_on('Regenerate')
    expect(page).to have_button('Start regeneration')
    expect(page).to have_content('Previous runs')
    expect(page).to have_content('pending')
    click_on('View')
    expect(page).to have_content('Status: pending')
    expect(page).to have_content('analysing..')
    expect(page).to have_content('bogus..')
  end
end
