require 'rails_helper'

describe 'Intervention Types', type: :system do
  let!(:admin)                    { create(:admin)}
  let!(:intervention_type_group)  { create(:intervention_type_group)}

  describe 'when not logged in' do
    it 'does not authorise viewing' do
      visit admin_intervention_types_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end

  describe 'when logged in as admin' do
    before do
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
      fill_in :intervention_type_name_en, with: title
      fill_in :intervention_type_summary_en, with: summary

      attach_file(:intervention_type_image_en, Rails.root + 'spec/fixtures/images/placeholder.png')

      within('.download-links-trix-editor.en') do
        fill_in_trix with: download_links
      end

      within('.description-trix-editor.en') do
        fill_in_trix with: description
      end

      fill_in('Score', with: 20)
      fill_in('Maximum frequency', with: 5)

      click_on('Create Intervention type')

      expect(page.has_content?('Intervention type was successfully created.')).to be true
      expect(InterventionType.count).to be 1

      intervention_type = InterventionType.first

      expect(intervention_type.name).to eq(title)
      expect(intervention_type.summary).to eq(summary)
      expect(intervention_type.image_en.filename).to eq('placeholder.png')
      expect(intervention_type.maximum_frequency).to eq(5)

      click_on title
      expect(page).to have_css("img[src*='placeholder.png']")
      expect(page).to have_content(download_links)
      expect(page).to have_content(summary)
      expect(page).to have_content(description)
    end

    it 'does not crash if you forget the score' do
      click_on('New Intervention type', match: :first)
      fill_in :intervention_type_name_en, with: 'New activity'
      fill_in_trix with: 'the description'

      click_on('Create Intervention type')

      expect(page.has_content?("Score can't be blank"))
      expect(InterventionType.count).to be 0
    end

    it 'can edit an intervention' do
      intervention_type = create(:intervention_type, intervention_type_group: intervention_type_group)
      refresh

      click_on 'Edit'

      title = 'New title'
      description = 'New description'
      summary = 'New summary'

      uncheck('Active')
      fill_in :intervention_type_name_en, with: title
      fill_in :intervention_type_summary_en, with: summary
      within('.description-trix-editor.en') do
        fill_in_trix with: description
      end

      fill_in('Maximum frequency', with: 5)

      click_on('Update Intervention type')
      expect(page.has_content?('Intervention type was successfully updated.')).to be true
      expect(InterventionType.count).to be 1

      intervention_type.reload
      expect(intervention_type.name).to eq(title)
      expect(intervention_type.summary).to eq(summary)
      expect(intervention_type.description.body.to_plain_text).to eq(description)
      expect(intervention_type.active?).to be false
      expect(intervention_type.maximum_frequency).to eq(5)
    end

    it 'shows user view from index' do
      intervention_type = create(:intervention_type, intervention_type_group: intervention_type_group, score: 99)
      refresh
      click_on intervention_type.name
      expect(page).to have_content('Overview')
      expect(page).to have_content('99 points for this action')
    end

    it 'can add and remove suggested next actions' do
      intervention_type = create(:intervention_type, intervention_type_group: intervention_type_group)
      refresh

      click_on 'Edit'
      within('.intervention_type_suggestions') do
        find(:xpath, "//option[contains(text(), '#{intervention_type.name}')]", match: :first).select_option
      end

      click_on('Update Intervention type')
      expect(page.has_content?('Intervention type was successfully updated.')).to be true
      intervention_type.reload
      expect(intervention_type.suggested_types).to match_array([intervention_type])

      click_on 'Edit'
      within('.intervention_type_suggestions') do
        first("input[type='checkbox']").check
      end

      click_on('Update Intervention type')
      expect(page.has_content?('Intervention type was successfully updated.')).to be true
      intervention_type.reload
      expect(intervention_type.suggested_types).to be_empty
    end

    it 'can update en and cy descriptions and show both' do
      intervention_type = create(:intervention_type)
      refresh

      click_on 'Edit'

      fill_in :intervention_type_summary_en, with: 'some english summary'
      fill_in :intervention_type_summary_cy, with: 'some welsh summary'

      within('.description-trix-editor.en') do
        fill_in_trix with: 'some english description'
      end

      within('.description-trix-editor.cy') do
        fill_in_trix with: 'some welsh description'
      end

      click_on('Update Intervention type')

      visit intervention_type_path(intervention_type)
      expect(page).to have_content('some english summary')
      expect(page).to have_content('some english description')
      expect(page).to have_link('Edit')

      visit intervention_type_path(intervention_type, locale: :cy)
      expect(page).to have_content('some welsh summary')
      expect(page).to have_content('some welsh description')
    end
  end
end
