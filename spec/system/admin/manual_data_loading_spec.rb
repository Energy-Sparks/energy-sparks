require 'rails_helper'

describe "manual data load", type: :system do
  let!(:admin)               { create(:admin) }

  before do
    sign_in(admin)
    visit root_path
    click_on("Reports")
  end

  it 'links to report' do
    click_on("Recent manual imports")
    expect(page).to have_content("Recent manual data loads")
  end

  context 'view the manual data load report' do
    let!(:runs)           { create_list(:manual_data_load_run, 22, status: :done) }

    let(:oldest_run)      { runs.first }
    let(:newest_run)      { runs.last }

    before do
      click_on("Recent manual imports")
    end

    it 'lists the data loads' do
      expect(page).to have_content(newest_run.amr_uploaded_reading.file_name)
      expect(page).not_to have_content(oldest_run.amr_uploaded_reading.file_name)
    end

    it 'has paging' do
      within '#paging-top' do
        expect(page).to have_link('Next')
        click_on('Next')
      end
      expect(page).not_to have_content(newest_run.amr_uploaded_reading.file_name)
      expect(page).to have_content(oldest_run.amr_uploaded_reading.file_name)
    end

    it 'displays the status' do
      first(:link, text: 'View', exact_text: true).click
      expect(page).to have_content(newest_run.amr_uploaded_reading.amr_data_feed_config.description)
      expect(page).to have_content(newest_run.amr_uploaded_reading.file_name)
      expect(page).to have_content("done")
    end
  end
end
