require 'rails_helper'

describe 'Jobs', type: :system do

  let!(:admin)  { create(:admin) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
    within '.application' do
      click_on 'Jobs'
    end
  end

  it 'allows the user to create, edit and delete a job' do
    title = 'New job'
    new_title = 'New job, updated'

    click_on 'New Job'
    fill_in_trix with: 'Help us do a thing really well'
    click_on 'Create'
    expect(page).to have_content('blank')
    fill_in 'Title', with: title
    attach_file("File", Rails.root + "spec/fixtures/images/newsletter-placeholder.png")
    check 'Voluntary'
    click_on 'Create'
    expect(page).to have_content title

    click_on 'Edit'
    fill_in 'Title', with: new_title
    click_on 'Update'

    expect(page).to have_content new_title

    click_on 'Delete'
    expect(page).to have_content('Job was successfully deleted.')
    expect(Job.count).to eq(0)
  end

end
