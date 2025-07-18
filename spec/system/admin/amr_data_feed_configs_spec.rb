# frozen_string_literal: true

require 'rails_helper'

describe AmrDataFeedConfig do
  let!(:admin)              { create(:admin) }
  let!(:config)             { create(:amr_data_feed_config, owned_by: admin) }
  let!(:disabled_config)    { create(:amr_data_feed_config, description: 'Disabled', enabled: false) }
  let!(:api_config)         { create(:amr_data_feed_config, description: 'API', source_type: :api) }

  before do
    sign_in(admin)
    visit root_path
  end

  context 'when viewing list of amr data feed configurations' do
    before do
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
    end

    it 'displays only enabled non-api configurations' do
      expect(page).to have_content(config.description)
      expect(page).to have_no_content(disabled_config.description)
      expect(page).to have_no_content(api_config.description)
    end

    it 'allows navigation to view the configuration' do
      within '#configuration-overview' do
        click_on config.description
      end
      expect(page).to have_content(config.description)
      expect(page).to have_content(config.owned_by.name)
    end

    it 'includes a limited view in the overview table' do
      expect(page).to have_css('#configuration-overview')
      within '#configuration-overview' do
        expect(page).to have_content(config.description)
        expect(page).to have_content(config.identifier)
        expect(page).to have_content(config.notes.to_plain_text)
        expect(page).to have_content(config.owned_by.name)
        expect(page).to have_link('Upload')
        expect(page).to have_link('Edit')
      end
    end

    it 'includes more detail in the detail table' do
      expect(page).to have_css('#configuration-detail')
      within '#configuration-detail' do
        expect(page).to have_content(config.number_of_header_rows)
        expect(page).to have_content(config.mpan_mprn_field)
        expect(page).to have_content(config.reading_date_field)
        expect(page).to have_content(config.date_format)
      end
    end
  end

  context 'when editing a configuration' do
    before do
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
    end

    it 'can edit amr data feed configuration' do
      within '#configuration-overview' do
        click_on 'Edit'
      end
      fill_in 'Description', with: 'New title'
      fill_in 'Import warning days', with: 21
      within('.amr_data_feed_config_notes') do
        fill_in_trix with: 'My notes'
      end
      fill_in 'Missing reading window', with: 2
      select 'Manual only', from: 'Source type'
      select admin.name, from: 'Owned by'
      click_on 'Update'
      config.reload
      expect(config.import_warning_days).to eq(21)
      expect(config.description).to eq('New title')
      expect(config.notes.to_plain_text).to eq('My notes')
      expect(config.missing_reading_window).to eq(2)
      expect(config.source_type).to eq('manual')
      expect(config.owned_by).to eq(admin)
    end
  end
end
