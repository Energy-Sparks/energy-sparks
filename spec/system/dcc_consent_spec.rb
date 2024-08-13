require 'rails_helper'

RSpec.describe 'DCC consents', type: :system do
  let(:school_name) { 'Oldfield Park Infants' }
  let!(:school_group) { create(:school_group) }
  let!(:school)       { create(:school, name: school_name, school_group:) }
  let!(:admin)        { create(:admin) }

  context 'as admin' do
    before do
      sign_in(admin)
      visit root_path
      click_on('Admin')
    end

    context 'when the school has a DCC meter' do
      let!(:meter_1) do
        create(:electricity_meter, dcc_meter: :smets2, consent_granted: false, name: 'Electricity meter', school:,
                                   mpan_mprn: 1_234_567_890_123)
      end
      let!(:meter_2) do
        create(:gas_meter, dcc_meter: :smets2, consent_granted: true, name: 'Gas meter', school:,
                           mpan_mprn: 987_654_321)
      end

      it 'the DCC consents counts are shown' do
        allow(Meters::N3rgyMeteringService).to receive(:consented_meters).and_return([])
        stub_request(:get, 'https://n3rgy.test/?maxResults=100&startAt=0')

        click_on('DCC Consents')
        expect(page).to have_content('DCC Consents')
        expect(page).to have_content('1234567890123')
        expect(page).to have_content('987654321')
        expect(page).to have_content('Total schools with DCC consents: 1')
        expect(page).to have_content('Total meters with DCC consents: 1')
        expect(page).to have_content(school_group.name)
        expect(page).to have_content(school_name)
        expect(page).to have_no_content('MPANs in n3rgy list but not in our DCC records')
      end

      it 'consents from API not in our records are shown' do
        allow(Meters::N3rgyMeteringService).to receive(:consented_meters).and_return(['998877'])
        # stub_request(:get, 'https://n3rgy.test/?maxResults=100&startAt=0').and_return
        click_on('DCC Consents')
        expect(page).to have_content('MPANs in n3rgy list but not in our DCC records')
        expect(page).to have_content('998877')
      end

      context 'when granting consent' do
        let!(:meter_review) { create(:meter_review, meters: [meter_1]) }

        it 'allows grant of consent' do
          stub_request(:get, 'https://n3rgy.test/find-mpxn/1234567890123').to_return(body: '{}')
          stub_request(:get, 'https://n3rgy.test/?maxResults=100&startAt=0')
          stub_request(:get, 'https://n3rgy.test/mpxn/1234567890123')
          stub_request(:post, 'https://n3rgy.test/consents/add-trusted-consent').with(
            body: { mpxn: meter_1.mpan_mprn.to_s,
                    evidence: meter_review.consent_grant.guid,
                    moveInDate: '2012-01-01' }.to_json
          )
          click_on('DCC Consents')
          click_on('1234567890123')
          expect(page).to have_content('1234567890123')
          click_on('Grant consent')
          expect(page).to have_content('Consent granted for 1234567890123')
          expect(meter_1.reload.consent_granted).to be_truthy
        end
      end

      context 'when withdrawing consent' do
        it 'allows withdrawal of consent' do
          stub_request(:get, 'https://n3rgy.test/find-mpxn/987654321').to_return(body: '{}')
          stub_request(:get, 'https://n3rgy.test/?maxResults=100&startAt=0')
          stub_request(:get, 'https://n3rgy.test/mpxn/987654321')
          stub = stub_request(:delete, 'https://n3rgy.test/consents/withdraw-consent/987654321')
          click_on('DCC Consents')
          click_on('987654321')
          expect(page).to have_content('987654321')
          click_on('Withdraw consent')
          expect(page).to have_content('Consent withdrawn for 987654321')
          expect(meter_1.reload.consent_granted).to be_falsey
          expect(stub).to have_been_requested
        end
      end
    end

    context 'when the school has an ungrouped DCC meter' do
      let!(:school_without_group) { create(:school) }
      let!(:meter_1) do
        create(:electricity_meter, dcc_meter: :smets2, name: 'Electricity meter', school: school_without_group,
                                   mpan_mprn: 1_234_567_890_123)
      end

      it 'the DCC consents counts are shown' do
        allow(Meters::N3rgyMeteringService).to receive(:consented_meters).and_return([''])
        click_on('DCC Consents')
        expect(page).to have_content('Ungrouped')
        expect(page).to have_content('1234567890123')
      end
    end
  end
end
