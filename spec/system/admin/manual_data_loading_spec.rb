require 'rails_helper'

describe "manual data load", type: :system do
  let!(:admin)               { create(:admin) }
  let!(:runs)                { create_list(:manual_data_load_run, 22, status: :done) }

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
    let(:run)      { ManualDataLoadRun.first }
    let(:last_run) { ManualDataLoadRun.last }

    before do
      click_on("Recent manual imports")
    end

    it 'lists the data loads' do
      expect(page).to have_content(run.amr_uploaded_reading.file_name)
      expect(page).not_to have_content(last_run.amr_uploaded_reading.file_name)
    end

    it 'has paging' do
      expect(page).to have_link('Next')
      click_on('Next')
      expect(page).not_to have_content(run.amr_uploaded_reading.file_name)
      expect(page).to have_content(last_run.amr_uploaded_reading.file_name)
    end

    it 'displays the status' do
      click_on("View")
      expect(page).to have_content(run.amr_uploaded_reading.amr_data_feed_config.description)
      expect(page).to have_content(run.amr_uploaded_reading.file_name)
      expect(page).to have_content("done")
    end
  end
end
