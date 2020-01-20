require 'rails_helper'

describe AmrReadingWarning, type: :system, include_application_helper: true do

  let(:mpan)      { '123' }
  let!(:admin)    { create(:admin) }
  let!(:log)      { create(:amr_data_feed_import_log) }
  let!(:warning)  { AmrReadingWarning.create(amr_data_feed_import_log: log, mpan_mprn: mpan, warning_types: [:missing_readings]) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows a benchmark result run and allows the user to drill down' do
    click_on 'AMR File imports report'
    click_on 'Warnings'

    expect(page).to have_content('Warnings')
    expect(page).to have_content(nice_date_times(log.import_time))
    expect(page).to have_content(mpan)
    expect(page).to have_content(AmrReadingData::WARNINGS[:missing_readings])
  end
end
