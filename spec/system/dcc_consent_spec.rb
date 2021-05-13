require 'rails_helper'

RSpec.describe "DCC consents", type: :system do

  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school_group)       { create(:school_group)}
  let!(:school)       { create(:school, name: school_name, school_group: school_group)}
  let!(:admin)        { create(:admin)}

  context 'as admin' do

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on('Admin')
    end

    context 'when the school has a DCC meter' do
      let!(:meter_1) { create(:electricity_meter, dcc_meter: true, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }
      let!(:meter_2) { create(:gas_meter, dcc_meter: true, name: 'Gas meter', school: school, mpan_mprn: 987654321 ) }

      it 'the DCC consents counts are shown' do
        allow_any_instance_of(MeterReadingsFeeds::N3rgyData).to receive(:list).and_return([])
        click_on('DCC Consents')
        expect(page).to have_content('DCC Consents')
        expect(page).to have_content('1234567890123')
        expect(page).to have_content('987654321')
        expect(page).to have_content('Total schools with DCC consents: 1')
        expect(page).to have_content('Total meters with DCC consents: 2')
        expect(page).to have_content(school_group.name)
        expect(page).to have_content(school_name)
        expect(page).not_to have_content('MPANs in n3rgy list but not in our DCC records')
      end

      it 'consents from API not in our records are shown' do
        allow_any_instance_of(MeterReadingsFeeds::N3rgyData).to receive(:list).and_return(['998877'])
        click_on('DCC Consents')
        expect(page).to have_content('MPANs in n3rgy list but not in our DCC records')
        expect(page).to have_content('998877')
      end
    end

    context 'when the school has a sandbox DCC meter' do
      let!(:meter_1) { create(:electricity_meter, dcc_meter: true, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }
      let!(:meter_2) { create(:gas_meter, dcc_meter: true, name: 'Gas meter', school: school, mpan_mprn: 987654321, sandbox: true ) }

      it 'the DCC consents counts are shown' do
        allow_any_instance_of(MeterReadingsFeeds::N3rgyData).to receive(:list).and_return([])
        click_on('DCC Consents')
        expect(page).to have_content('1234567890123')
        expect(page).not_to have_content('987654321')
        expect(page).to have_content('Total schools with DCC consents: 1')
        expect(page).to have_content('Total meters with DCC consents: 1')
        click_on('Show with sandbox meters')
        expect(page).to have_content('1234567890123')
        expect(page).to have_content('987654321')
        expect(page).to have_content('Total schools with DCC consents: 1')
        expect(page).to have_content('Total meters with DCC consents: 2')
        expect(page).to have_link('Show without sandbox meters')
      end
    end
<<<<<<< HEAD

    context 'when the school has an ungrouped DCC meter' do
      let!(:school_without_group) { create(:school) }
      let!(:meter_1) { create(:electricity_meter, dcc_meter: true, name: 'Electricity meter', school: school_without_group, mpan_mprn: 1234567890123 ) }

      it 'the DCC consents counts are shown' do
        allow_any_instance_of(MeterReadingsFeeds::N3rgyData).to receive(:list).and_return([])
        click_on('DCC Consents')
        expect(page).to have_content('Ungrouped')
        expect(page).to have_content('1234567890123')
      end
    end
=======
>>>>>>> 5142cf59... Show with or without sandbox meters
  end
end
