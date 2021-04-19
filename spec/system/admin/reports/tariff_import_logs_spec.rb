require 'rails_helper'

describe TariffImportLog, type: :system, include_application_helper: true do

  let!(:admin)           { create(:admin) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows import logs' do
    error_messages = "Oh no!"
    log_1 = create(:tariff_import_log, error_messages: error_messages, import_time: 1.day.ago)
    log_2 = create(:tariff_import_log, standing_charges_imported: 111, standing_charges_updated: 222, prices_imported: 333, prices_updated: 444, import_time: 1.day.ago)

    click_on 'Tariff imports report'
    expect(page).to have_content('Tariff Import Logs')
    expect(page).to have_content(nice_date_times(log_1.import_time))
    expect(page).to have_content(nice_date_times(log_2.import_time))

    expect(page).to have_content(111)
    expect(page).to have_content(222)
    expect(page).to have_content(333)
    expect(page).to have_content(444)
    expect(page).to have_content(error_messages)
  end
end
