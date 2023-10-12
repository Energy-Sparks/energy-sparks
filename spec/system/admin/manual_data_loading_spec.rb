require 'rails_helper'

describe "manual data load", type: :system do
  let!(:admin)              { create(:admin) }

  let!(:run)                { create(:manual_data_load_run, status: :done) }

  before(:each) do
    sign_in(admin)
    visit root_path
  end

  describe 'report' do
    before(:each) do
      click_on("Reports")
    end

    it 'links to report' do
      click_on("Recent manual imports")
      expect(page).to have_content("Recent manual data loads")
    end

    it 'lists the data loads' do
      click_on("Recent manual imports")
      expect(page).to have_content(run.amr_uploaded_reading.file_name)
    end

    it 'displays the status' do
      click_on("Recent manual imports")
      click_on("View")
      expect(page).to have_content(run.amr_uploaded_reading.amr_data_feed_config.description)
      expect(page).to have_content(run.amr_uploaded_reading.file_name)
      expect(page).to have_content("done")
    end
  end
end
