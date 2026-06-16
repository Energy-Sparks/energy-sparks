require 'rails_helper'

describe TariffImportLog, :include_application_helper, type: :system do
  let!(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows import logs' do
    error_messages = 'Oh no!'
    log_1 = create(:tariff_import_log, description: 'import one', error_messages: error_messages, import_time: 2.days.ago)
    log_2 = create(:tariff_import_log, description: 'import two', standing_charges_imported: 111, standing_charges_updated: 222, prices_imported: 333, prices_updated: 444, import_time: 1.day.ago)

    click_on 'Tariff imports report'
    expect(page).to have_text('Tariff Import Logs')
    expect(page).to have_text('import one')
    expect(page).to have_text('import two')
    expect(page).to have_text(nice_date_times(log_1.import_time).strip)
    expect(page).to have_text(nice_date_times(log_2.import_time).strip)

    expect(page).to have_text(111)
    expect(page).to have_text(222)
    expect(page).to have_text(333)
    expect(page).to have_text(444)
    expect(page).to have_text(error_messages)
  end
end
