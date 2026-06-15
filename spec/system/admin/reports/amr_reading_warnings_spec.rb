require 'rails_helper'

describe AmrReadingWarning, type: :system, include_application_helper: true do
  let(:mpan)      { '123' }
  let!(:admin)    { create(:admin) }
  let!(:log)      { create(:amr_data_feed_import_log) }
  let!(:warning)  { AmrReadingWarning.create(amr_data_feed_import_log: log, mpan_mprn: mpan, warning_types: [AmrReadingWarning::WARNINGS.key(:missing_readings)]) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows a benchmark result run and allows the user to drill down' do
    click_on 'Data feed import logs'
    click_on 'Warnings'

    expect(page).to have_content('Warnings')
    expect(page).to have_content(nice_date_times(log.import_time))
  end
end
