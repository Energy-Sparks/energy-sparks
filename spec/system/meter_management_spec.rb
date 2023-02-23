require 'rails_helper'

RSpec.shared_examples_for "a listed meter" do |admin: true|
  it "displays list heading" do
    if meter.active
      expect(page).to have_content("Active meters")
    else
      expect(page).to have_content("Inactive meters")
    end
  end
  it { expect(page).to have_content(meter.mpan_mprn) }
  it { expect(page).to have_content(meter.name) }
  it { expect(page).to have_content(short_dates(meter.first_validated_reading)) }
  it { expect(page).to have_content(short_dates(meter.last_validated_reading)) }
  it { expect(page).to have_content(meter.zero_reading_days.count) }
  it { expect(page).to have_content(meter.gappy_validated_readings.count) }
  if admin
    it { expect(page).to have_button('Issues') }
    it { expect(page).to have_link(meter.data_source.name) }
  else
    it { expect(page).to_not have_button('Issues') }
    it { expect(page).to_not have_link(meter.data_source.name) }
  end
end

RSpec.describe "meter management", :meters, type: :system, include_application_helper: true do

  let(:school_name)     { 'Oldfield Park Infants'}
  let!(:school)         { create_active_school(name: school_name)}
  let!(:admin)          { create(:admin)}
  let!(:teacher)        { create(:staff)}
  let!(:school_admin)   { create(:school_admin, school_id: school.id) }
  let!(:data_source)    { create(:data_source, name: 'Data Co') }
  let(:active_meter)    { create(:gas_meter_with_validated_reading_dates, name: 'meter', school: school, data_source: data_source) }
  let(:inactive_meter)  { create(:gas_meter_with_validated_reading_dates, name: 'meter', school: school, data_source: data_source, active: false) }
  let!(:setup_data)     { }

  context 'as school admin' do
    before(:each) do
      sign_in(school_admin)
      visit root_path
    end

    context 'when the school has a meter with no readings' do
      let!(:gas_meter) { create :gas_meter, name: 'Gas meter', school: school }

      it 'allows deletion of inactive meters' do
        click_on 'Manage meters'
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end
    end

    context 'when the school has a meter with readings' do
      let!(:meter) { create(:electricity_meter_with_reading, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }

      it 'the meter cannot be deleted' do
        click_on 'Manage meters'
        click_on 'Deactivate'
        expect(meter.amr_data_feed_readings.count).to eq(1)
        expect(page).to have_button('Delete', disabled: true)
      end
    end

    context 'when the school has a DCC meter' do
      let!(:meter) { create(:electricity_meter, dcc_meter: true, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }

      let!(:data_api) { double(find: true, inventory: {device_id: 123999}, elements: [1]) }

      before(:each) do
        allow_any_instance_of(Amr::N3rgyApiFactory).to receive(:data_api).with(meter).and_return(data_api)
      end

      it 'the meter inventory button is not shown' do
        click_on 'Manage meters'
        click_on 'Details'
        expect(page).not_to have_button('Inventory')
      end

      it 'the tariff report button is not shown' do
        click_on 'Manage meters'
        click_on 'Details'
        expect(page).not_to have_button('Tariff Report')
      end

      it 'the attributes button is not shown' do
        click_on 'Manage meters'
        click_on 'Details'
        expect(page).not_to have_button('Attributes')
      end
    end

    context "Manage meters page" do
      before { visit school_meters_path(school) }
      it_behaves_like "admin dashboard messages", permitted: false

      context "Add meter form" do
        it "does not display admin only fields" do
          expect(page).to_not have_content('Data source')
        end
      end

      context "listing meters" do
        let!(:setup_data) { meter }

        it_behaves_like "a listed meter", admin: false do
          let(:meter) { active_meter }
        end
        it_behaves_like "a listed meter", admin: false do
          let(:meter) { inactive_meter }
        end
      end
    end
  end

  context 'as teacher' do
    before(:each) do
      sign_in(teacher)
      visit school_meters_path(school)
    end

    it 'does not see things it should not' do
      expect(page).to_not have_content('Delete')
      expect(page).to_not have_content('Create Meter')
      expect(page).to_not have_content('Activate')
      expect(page).to_not have_content('Deactivate')
    end

    it_behaves_like "admin dashboard messages", permitted: false

    context "Add meter form" do
      it "does not display admin only fields" do
        expect(page).to_not have_content('Data source')
      end
    end

    context "listing meters" do
      let(:setup_data) { meter }

      it_behaves_like "a listed meter", admin: false do
        let(:meter) { active_meter }
      end
      it_behaves_like "a listed meter", admin: false do
        let(:meter) { inactive_meter }
      end
    end
  end

  context 'as admin' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on('View schools')
      click_on('Oldfield Park Infants')
    end

    context "Manage meters page" do
      before { click_on 'Manage meters' }

      it_behaves_like "admin dashboard messages" do
        let(:messageable) { school }
      end

      context "listing meters" do
        let!(:setup_data) { meter }

        it_behaves_like "a listed meter", admin: true do
          let(:meter) { active_meter }
        end
        it_behaves_like "a listed meter", admin: true do
          let(:meter) { inactive_meter }
        end
      end

      context "with meter issues" do
        let(:meter) { active_meter }
        let!(:issue) { create(:issue, issueable: school, meters: [meter], created_by: admin, updated_by: admin)}
        let!(:setup_data) { issue }

        context "Clicking Issues button" do
          before { click_on "Issues" }
          it_behaves_like "a displayed issue" do
            let(:user) { admin }
            let(:issue_admin) { admin }
          end
          it { expect(page).to have_link("New Note") }
          it { expect(page).to have_link("New Issue") }
        end
      end
    end

    context 'when the school has a DCC meter' do
      let!(:meter) { create(:electricity_meter, dcc_meter: true, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }
      let!(:data_api) { double(find: true, inventory: {device_id: 123999}, elements: [1]) }

      before(:each) do
        allow_any_instance_of(Amr::N3rgyApiFactory).to receive(:data_api).with(meter).and_return(data_api)
      end

      it 'the meter inventory button can be shown' do
        click_on 'Manage meters'
        click_on 'Details'
        click_on 'Inventory'
        expect(page).to have_content('device_id')
        expect(page).to have_content('123999')
      end

      it 'the tariff report can be shown' do
        click_on 'Manage meters'
        click_on 'Details'
        click_on 'Tariff Report'
        expect(page).to have_content("Standing charges")
      end

      it 'the single meter attributes view can be shown' do
        click_on 'Manage meters'
        click_on 'Details'
        click_on 'Attributes'
        expect(page).to have_content("Individual Meter attributes")
      end

      it 'the dcc checkboxes and status are shown on the edit form' do
        click_on 'Manage meters'
        click_on 'Edit'
        check "DCC Smart Meter"
        check "Sandbox"
        click_on 'Update Meter'
        meter.reload
        expect(meter.dcc_meter).to be true
      end
    end

    context 'when creating meters' do
      let!(:data_api) { double(find: true, inventory: {device_id: 123999}, elements: [1]) }

      before(:each) do
        allow_any_instance_of(Amr::N3rgyApiFactory).to receive(:data_api).and_return(data_api)
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
        expect(school.meters.first.mpan_mprn).to eq(123543)
        expect(school.meters.first.data_source.name).to eq('Data Co')
      end
    end

    context 'when the school has a meter' do
      let!(:gas_meter) { create :gas_meter, name: 'Gas meter', school: school }
      before(:each) {
        click_on 'Manage meters'
      }

      it 'allows editing' do
        click_on 'Edit'
        fill_in 'Name', with: 'Natural Gas Meter'
        select 'Data Co', from: 'Data source'
        click_on 'Update Meter'
        gas_meter.reload
        expect(gas_meter.name).to eq('Natural Gas Meter')
        expect(gas_meter.data_source.name).to eq('Data Co')
      end

      it 'allows deactivation and reactivation of a meter' do
        click_on 'Deactivate'

        gas_meter.reload
        expect(gas_meter.active).to eq(false)

        click_on 'Activate'
        gas_meter.reload
        expect(gas_meter.active).to eq(true)
      end

      context 'with a school target' do
        let!(:school_target)  { create(:school_target, school: school) }

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
        expect(page).to_not have_content('CSV')
      end
    end

    context 'when the school has a meter with readings' do
      let!(:meter) { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school) }

      before(:each) do
        allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
      end

      before(:each) {
        click_on 'Manage meters'
      }

      it 'allows deletion of inactive meters' do
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end
    end

    context 'when checking target data' do
      context 'and there is enough' do
        before(:each) do
          allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
          click_on 'Manage meters'
        end

        it 'should say' do
          expect(page).to have_content("This school has enough data for at least one fuel type to generate targets")
        end
        it 'should link to detail' do
          expect(page).to have_link("View target data", href: admin_school_target_data_path(school))
        end
      end

      context 'and there is not enough' do
        before(:each) do
          allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(false)
          click_on 'Manage meters'
        end

        it 'should say' do
          expect(page).to have_content("This school does not have enough data to generate targets")
        end

        it 'should link to detail' do
          expect(page).to have_link("View target data", href: admin_school_target_data_path(school))
        end
      end
    end
  end
end
