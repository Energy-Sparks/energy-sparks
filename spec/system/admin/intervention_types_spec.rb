require 'rails_helper'

describe "Intervention Types", type: :system do

  let!(:admin)                    { create(:admin)}
  let!(:intervention_type_group)  { create(:intervention_type_group)}

  describe 'when not logged in' do
    it 'does not authorise viewing' do
      visit admin_intervention_types_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end

  describe 'when logged in as admin' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Intervention Types'
      expect(ActivityType.count).to be 0
    end

    it 'can add a new intervention type' do
      title = 'New activity'
      summary = 'An activity to try'
      description = 'The description'
      download_links = 'Some download links'

      click_on('New Intervention type', match: :first)
      fill_in('Title', with: title)
      fill_in('Summary', with: summary)

      attach_file("intervention_type_image", Rails.root + "spec/fixtures/images/placeholder.png")

      within('.download-links-trix-editor') do
        fill_in_trix with: download_links
      end

      within('.description-trix-editor') do
        fill_in_trix with: description
      end

      fill_in('Score', with: 20)

      click_on('Create Intervention type')

      expect(page.has_content?("Intervention type was successfully created.")).to be true
      expect(InterventionType.count).to be 1

      intervention_type = InterventionType.first

      expect(intervention_type.title).to eq(title)
      expect(intervention_type.summary).to eq(summary)
      expect(intervention_type.image.filename).to eq('placeholder.png')

      click_on title
      expect(page).to have_css("img[src*='placeholder.png']")
      expect(page).to have_content(download_links)
      expect(page).to have_content(summary)
      expect(page).to have_content(description)
    end

    it 'can does not crash if you forget the score' do
      click_on('New Intervention type', match: :first)
      fill_in('Title', with: 'New activity')
      fill_in_trix with: "the description"

      click_on('Create Intervention type')

      expect(page.has_content?("Score can't be blank"))
      expect(InterventionType.count).to be 0
    end

    it 'can edit a new activity' do
      intervention_type = create(:intervention_type, intervention_type_group: intervention_type_group )
      refresh

      click_on 'Edit'

      title = "New title"
      description = "New description"
      summary = "New summary"

      uncheck('Active')
      fill_in 'Title', with: title
      fill_in 'Summary', with: summary
      within('.description-trix-editor') do
        fill_in_trix with: description
      end

      click_on('Update Intervention type')
      expect(page.has_content?("Intervention type was successfully updated.")).to be true
      expect(InterventionType.count).to be 1

      intervention_type.reload
      expect(intervention_type.title).to eq(title)
      expect(intervention_type.summary).to eq(summary)
      expect(intervention_type.description.body.to_plain_text).to eq(description)
      expect(intervention_type.active?).to be false
    end
  end
end
