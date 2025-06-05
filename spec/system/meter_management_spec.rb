# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples_for 'a listed meter' do |admin: true|
  it 'displays list heading' do
    if meter.active
      expect(page).to have_content('Active meters')
    else
      expect(page).to have_content('Inactive meters')
    end
  end

  it 'displays meter' do
    expect(page).to have_content(meter.mpan_mprn)
    expect(page).to have_content(meter.name)
    expect(page).to have_content(short_dates(meter.first_validated_reading))
    expect(page).to have_content(short_dates(meter.last_validated_reading))
    expect(page).to have_content(meter.zero_reading_days.count)
    expect(page).to have_content(meter.gappy_validated_readings.count)
    if admin
      expect(page).to have_link('Issues')
      expect(page).to have_link(meter.data_source.name)
    else
      expect(page).to have_no_link('Issues')
      expect(page).to have_no_link(meter.data_source.name)
    end
  end
end

RSpec.shared_examples_for 'the show meter page' do |admin:|
  it 'displays the correct fields' do
    click_on meter.mpan_mprn.to_s
    expect(page).to have_text('Basic information')
    expect(page).to have_text("MPAN/MPRN #{meter.mpan_mprn} Serial Number Type #{meter.meter_type.titleize}")
    expect(page).to have_selector(:link_or_button, 'Edit', exact: true)
    if admin
      expect(page).to have_text('Admin details')
      expect(page).to have_text('Meter system NHH AMR Data source Data Co Contract Meter status Manual reads? false ' \
                                'Gas unit Cubic Meters')
    else
      expect(page).to have_no_text('Admin details')
    end
  end
end

RSpec.describe 'meter management', :include_application_helper, :meters do
  include ActiveJob::TestHelper

  let(:school_name)     { 'Oldfield Park Infants' }
  let!(:school)         { create_active_school(name: school_name) }
  let!(:admin)          { create(:admin) }
  let!(:teacher)        { create(:staff) }
  let!(:school_admin)   { create(:school_admin, school_id: school.id) }
  let!(:data_source)    { create(:data_source, name: 'Data Co') }
  let(:active_meter)    do
    create(:gas_meter_with_validated_reading_dates, name: 'meter', school:, data_source:, gas_unit: :m3)
  end
  let(:inactive_meter) do
    create(:gas_meter_with_validated_reading_dates, name: 'meter', school:, data_source:, active: false)
  end
  let!(:setup_data) {}

  around do |example|
    create(:amr_data_feed_config, identifier: 'perse-half-hourly-api')
    example.run
  end

  context 'when a school admin' do
    before do
      sign_in(school_admin)
      visit root_path
    end

    context 'when the school has a meter with no readings' do
      let!(:gas_meter) { create(:gas_meter, name: 'Gas meter', school:) }

      it 'allows deletion of inactive meters' do
        click_on 'Manage meters'
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end
    end

    context 'when the school has a meter with readings' do
      let!(:meter) do
        create(:electricity_meter_with_reading, name: 'Electricity meter', school:, mpan_mprn: 1_234_567_890_123)
      end

      before { click_on 'Manage meters' }

      it 'the meter cannot be deleted' do
        click_on 'Deactivate'
        expect(meter.amr_data_feed_readings.count).to eq(1)
        expect(page).to have_button('Delete', disabled: true)
      end

      it_behaves_like 'the show meter page', admin: false
    end

    context 'when the school has a DCC meter' do
      let!(:meter) do
        create(:electricity_meter, dcc_meter: :smets2, name: 'Electricity meter', school:, mpan_mprn: 1_234_567_890_123)
      end

      let!(:stub) do
        instance_double(Meters::N3rgyMeteringService, status: :available, available?: true,
                                                      consented?: true, available_data: Time.zone.today..Time.zone.today)
      end

      before do
        allow(Meters::N3rgyMeteringService).to receive(:new).and_return(stub)
        click_on 'Manage meters'
        click_on meter.mpan_mprn.to_s
      end

      it 'the meter inventory button is not shown' do
        expect(page).to have_no_selector(:link_or_button, 'Inventory')
      end

      it 'the tariff report button is not shown' do
        expect(page).to have_no_selector(:link_or_button, 'Tariff Report')
      end

      it 'the attributes button is not shown' do
        expect(page).to have_no_selector(:link_or_button, 'Attributes')
      end

      it 'the reload button is not shown' do
        expect(page).to have_no_selector(:link_or_button, 'Reload')
      end

      it 'does not admin only sections' do
        expect(page).to have_no_text('DCC (SMETS2) information')
        expect(page).to have_no_text('Perse Metering')
      end
    end

    context 'Manage meters page' do
      before { visit school_meters_path(school) }

      it_behaves_like 'admin dashboard messages', permitted: false

      context 'Add meter form' do
        it 'does not display admin only fields' do
          expect(page).to have_no_content('Data source')
        end
      end

      context 'listing meters' do
        let!(:setup_data) { meter }

        it_behaves_like 'a listed meter', admin: false do
          let(:meter) { active_meter }
        end
        it_behaves_like 'a listed meter', admin: false do
          let(:meter) { inactive_meter }
        end
      end
    end
  end

  context 'as teacher' do
    before do
      sign_in(teacher)
      visit school_meters_path(school)
    end

    it 'does not see things it should not' do
      expect(page).to have_no_content('Delete')
      expect(page).to have_no_content('Create Meter')
      expect(page).to have_no_content('Activate')
      expect(page).to have_no_content('Deactivate')
    end

    it_behaves_like 'admin dashboard messages', permitted: false

    context 'Add meter form' do
      it 'does not display admin only fields' do
        expect(page).to have_no_content('Data source')
      end
    end

    context 'listing meters' do
      let(:setup_data) { meter }

      it_behaves_like 'a listed meter', admin: false do
        let(:meter) { active_meter }
      end
      it_behaves_like 'a listed meter', admin: false do
        let(:meter) { inactive_meter }
      end
    end

    it_behaves_like 'the show meter page', admin: false do
      let(:setup_data) { meter }
      let(:meter) { active_meter }
    end
  end

  context 'when an admin' do
    before do
      sign_in(admin)
      visit school_path(school)
    end

    context 'with the Manage meters page' do
      before do
        stub_request(:get, "https://n3rgy.test/find-mpxn/#{active_meter.mpan_mprn}")
        click_on 'Manage meters'
      end

      it_behaves_like 'admin dashboard messages' do
        let(:messageable) { school }
      end

      it_behaves_like 'the show meter page', admin: true do
        let(:meter) { active_meter }
      end

      context 'listing meters' do
        let!(:setup_data) { meter }

        it_behaves_like 'a listed meter', admin: true do
          let(:meter) { active_meter }
        end
        it_behaves_like 'a listed meter', admin: true do
          let(:meter) { inactive_meter }
        end
      end

      context 'without meter issues' do
        let(:meter) { active_meter }
        let!(:setup_data) { meter }

        before { stub_request(:get, "https://n3rgy.test/find-mpxn/#{meter.mpan_mprn}") }

        it { expect(page).to have_link('Issues') }
        it { expect(page).to have_css("i[class*='fa-exclamation-circle']") }
        it { expect(page).to have_no_css("i[class*='fa-exclamation-circle text-danger']") }

        context "Clicking on meter 'Details'" do
          before do
            click_link meter.mpan_mprn.to_s
          end

          it { expect(page).to have_link('Issues') }
          it { expect(page).to have_no_css("i[class*='fa-exclamation-circle text-danger']") }
        end
      end

      context 'with meter issues' do
        let(:meter) { active_meter }
        let!(:issue) { create(:issue, issueable: school, meters: [meter], created_by: admin, updated_by: admin) }
        let!(:setup_data) { issue }

        it { expect(page).to have_link('Issues') }
        it { expect(page).to have_css("i[class*='fa-exclamation-circle text-danger']") }

        context "Clicking on meter 'Details'" do
          before { click_link meter.mpan_mprn.to_s }

          it { expect(page).to have_link('Issues') }
          it { expect(page).to have_css("i[class*='fa-exclamation-circle text-danger']") }
        end
      end
    end

    context 'when the school has a DCC meter' do
      let!(:meter) do
        create(:electricity_meter, dcc_meter: :smets2, name: 'Electricity meter', school:, mpan_mprn: 1_234_567_890_123)
      end

      before do
        stub_request(:get, 'https://n3rgy.test/find-mpxn/1234567890123').to_return(body: '{}')
        stub_request(:get, 'https://n3rgy.test/mpxn/1234567890123').to_return(body: '{}')
        stub_request(:get, %r{^https://n3rgy.test/mpxn/1234567890123/utility/electricity/readingtype/consumption?})
          .to_return(body: { availableCacheRange: { start: Time.zone.today.to_s, end: Time.zone.today.to_s } }.to_json)
        click_on 'Manage meters'
      end

      it 'shows the status and dates' do
        click_on meter.mpan_mprn.to_s
        expect(page).to have_content('Available')
        expect(page).to have_content(Time.zone.today.rfc2822)
      end

      it 'the meter inventory button can be shown' do
        stub_request(:post, 'https://n3rgy.test/read-inventory').to_return(body: { uri: 'details' }.to_json)
        stub_request(:get, 'https://n3rgy.test/details').to_return(body: { details: 999 }.to_json)
        click_on meter.mpan_mprn.to_s
        click_on 'Inventory'
        expect(page).to have_content('details')
        expect(page).to have_content('999')
      end

      it 'the tariff report can be shown' do
        click_on meter.mpan_mprn.to_s
        click_on 'Tariff Report'
        expect(page).to have_content('Smart meter tariffs')
      end

      it 'the dcc checkboxes and status are shown on the edit form' do
        click_on 'Edit'
        expect(page).to have_select('DCC Smart Meter', selected: 'Smets2')
        select 'Other', from: 'DCC Smart Meter'
        click_on 'Update Meter'
        expect(meter.reload.dcc_meter).to eq('other')
      end

      def expect_meter_reload
        expect(page).to have_text('Reload queued')
        expect { perform_enqueued_jobs }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(ActionMailer::Base.deliveries.last.subject).to \
          eq("[energy-sparks-unknown] Reload of Meter Electricity meter for #{school.name} complete")
        expect(ActionMailer::Base.deliveries.last.to).to eq([admin.email])
        expect(ActionMailer::Base.deliveries.last.to_s).to include('0 records were imported and 0 were updated')
      end

      it 'allows reloading the meter' do
        create(:amr_data_feed_config, process_type: :n3rgy_api, source_type: :api)
        click_on meter.mpan_mprn.to_s
        expect { click_on 'Reload' }.to have_enqueued_job(N3rgyReloadJob)
        expect_meter_reload
      end

      context 'with Perse' do
        around do |example|
          travel_to(Date.new(2024, 12, 10))
          create(:amr_data_feed_reading, # make sure we're doing a full reload
                 amr_data_feed_config: AmrDataFeedConfig.find_by!(identifier: 'perse-half-hourly-api'),
                 reading_date: '2024-12-10',
                 meter: meter)
          stub_request(:get, 'http://perse/meterhistory/v2/realtime-data?MPAN=1234567890123&fromDate=2023-10-10')
          meter.update!(perse_api: :half_hourly)
          ClimateControl.modify PERSE_API_URL: 'http://perse', PERSE_API_KEY: 'key' do
            example.run
          end
        end

        it 'allows reloading the meter with Perse' do
          click_on meter.mpan_mprn.to_s
          expect { click_on 'Reload' }.to have_enqueued_job(PerseReloadJob)
          expect_meter_reload
        end

        it 'allows reloading the meter with Perse and no DCC' do
          meter.update!(dcc_meter: :no)
          click_on meter.mpan_mprn.to_s
          expect { click_on 'Reload' }.to have_enqueued_job(PerseReloadJob)
          expect_meter_reload
        end

        it 'shows the last reading' do
          click_on meter.mpan_mprn.to_s
          expect(page).to have_text("Perse Metering\nPerse API Half Hourly Latest reading 2024-12-10\n")
        end
      end
    end

    context 'when creating meters' do
      let!(:stub) do
        instance_double(Meters::N3rgyMeteringService, status: :available, available?: true, consented?: true, inventory: { device_id: 123_999 },
                                                      available_data: Time.zone.today..Time.zone.today)
      end

      before do
        allow(Meters::N3rgyMeteringService).to receive(:new).and_return(stub)
      end

      it 'allows adding of meters from the management page with validation' do
        click_on('Manage meters')

        click_on 'Create Meter'
        expect(page).to have_content("Meter type can't be blank")

        fill_in 'Meter Point Number', with: '123543'
        fill_in 'Name', with: 'Gas'
        choose 'Gas'
        select 'Data Co', from: 'Data source'
        click_on 'Create Meter'

        expect(school.meters.count).to eq(1)
        expect(school.meters.first.mpan_mprn).to eq(123_543)
        expect(school.meters.first.data_source.name).to eq('Data Co')
      end
    end

    context 'when the school has a meter' do
      let!(:gas_meter) { create(:gas_meter, name: 'Gas meter', school:) }

      before do
        click_on 'Manage meters'
      end

      it 'allows editing' do
        click_on 'Edit'
        fill_in 'Name', with: 'Natural Gas Meter'
        select 'Data Co', from: 'Data source'
        check('Manual reads?')
        select 'Cubic Feet', from: 'Gas unit'
        click_on 'Update Meter'
        gas_meter.reload
        expect(gas_meter.name).to eq('Natural Gas Meter')
        expect(gas_meter.data_source.name).to eq('Data Co')
        expect(gas_meter.manual_reads).to be true
        expect(gas_meter.gas_unit).to eq('ft3')
      end

      it 'allows deactivation and reactivation of a meter' do
        click_on 'Deactivate'

        gas_meter.reload
        expect(gas_meter.active).to be(false)

        click_on 'Activate'
        gas_meter.reload
        expect(gas_meter.active).to be(true)
      end

      context 'with a school target' do
        let!(:school_target)  { create(:school_target, school:) }

        it 'fuel type changes are flagged when meters are activated and deactivated' do
          click_on 'Deactivate'
          click_on 'Activate'
          school_target.reload
          expect(school_target.suggest_revision?).to be true
        end
      end

      it 'allows deletion of inactive meters' do
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end

      it 'does not show the CSV download button if no readings' do
        expect(gas_meter.amr_validated_readings.empty?).to be true
        expect(page).to have_no_content('CSV')
      end

      it 'has Perse details' do
        stub_request(:get, "https://n3rgy.test/find-mpxn/#{gas_meter.mpan_mprn}")
        click_on gas_meter.mpan_mprn.to_s
        expect(page).to have_content('Perse API None')
      end
    end

    context 'when the school has a meter with readings' do
      let!(:meter) { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school:) }

      before do
        allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        click_on 'Manage meters'
      end

      it 'allows deletion of inactive meters' do
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end
    end
  end
end
