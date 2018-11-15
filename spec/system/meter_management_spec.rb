require 'rails_helper'

RSpec.describe "meter management", :meters, type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:admin)  { create(:user, role: 'admin')}

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on('Schools')
    click_on('Oldfield Park Infants')
  end

  it 'allows adding of meters from the management page with validation' do

    click_on('Manage meters')

    click_on 'Create Meter'
    expect(page).to have_content("Meter type can't be blank")

    fill_in 'Meter Point Number', with: '123543'
    fill_in 'Meter Name', with: 'Gas'
    choose 'Gas'
    click_on 'Create Meter'

    expect(school.meters.count).to eq(1)
    expect(school.meters.first.meter_no).to eq(123543)

  end

  context 'when the school has a meter' do

    let!(:gas_meter) { create :meter, name: 'Gas meter', school: school }

    it 'allows editing' do
      click_on('Manage meters')
      click_on 'Edit'
      fill_in 'Name', with: 'Natural Gas Meter'
      click_on 'Update Meter'
      gas_meter.reload
      expect(gas_meter.name).to eq('Natural Gas Meter')
    end

    it 'allows deactivation and reactivation of a meter'
    it 'allows deletion of inactive meters'

  end

end
