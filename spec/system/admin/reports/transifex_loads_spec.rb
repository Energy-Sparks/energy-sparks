require 'rails_helper'

describe 'TransifexLoads', type: :system, include_application_helper: true do
  let(:admin)                   { create(:admin) }
  let!(:transifex_load)         { create(:transifex_load, pulled: 6, pushed: 7) }
  let!(:transifex_load_error)   { create(:transifex_load_error) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'has link to report' do
    expect(page).to have_link('Transifex Content Loads')
    click_on 'Transifex Content Loads'
    expect(page).to have_content('Transifex Content Loads')
  end

  context 'viewing report' do
    before do
      click_on 'Transifex Content Loads'
    end

    it 'shows reports' do
      expect(page).to have_content(nice_dates(transifex_load.created_at))
    end

    it 'links to reports' do
      expect(page).to have_link('View', href: admin_reports_transifex_load_path(transifex_load.id))
      expect(page).to have_link('View', href: admin_reports_transifex_load_path(transifex_load_error.transifex_load.id))
    end
  end

  context 'viewing a report with errors' do
    before do
      visit admin_reports_transifex_load_path(transifex_load_error.transifex_load)
    end

    it 'shows errors' do
      expect(page).to have_content('1 error occured')
      expect(page).to have_content('A problem occured')
    end
  end

  context 'viewing a report without errors' do
    before do
      visit admin_reports_transifex_load_path(transifex_load)
    end

    it 'shows a summary' do
      expect(page).to have_content('pulled 6 resources')
      expect(page).to have_content('pushed 7 resources')
      expect(page).to have_content('0 errors occured')
    end
  end
end
