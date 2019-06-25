require 'rails_helper'

RSpec.describe "analysis view", type: :system do

  let(:school_name) { 'Theresa Green Infants'}
  let(:school)     { create(:school, :with_school_group, name: school_name, floor_area: nil)}

  it 'redirects back to the school home page if no meters are set' do
    visit school_analysis_path(school)
    expect(page).to have_content 'Analysis is currently unavailable due to a lack of validated meter readings'
  end

  context 'when a school has an electricity meter' do
    let!(:meter) { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school) }

    it 'requests for floor area and pupil numbers to be populated' do
      stub_out_the_aggregation_etc
      visit school_analysis_path(school)
      expect(page).to have_content('Please edit the school details')
    end

    it 'does not request for floor area and pupil numbers to be populated if they are' do
      floor_area = 20
      number_of_pupils = 100
      school.update(floor_area: floor_area, number_of_pupils: number_of_pupils)
      stub_out_the_aggregation_etc
      visit school_analysis_path(school)
      expect(page).to_not have_content('Please edit the school details')
      expect(page).to have_content(floor_area)
      expect(page).to have_content(number_of_pupils)
    end

    it 'allows units to be selected', js: :true do
      stub_out_the_aggregation_etc
      visit school_analysis_path(school)
      expect(page).to have_content('Currently your measurements are in energy used in kilowatt-hours')
      click_on('Change energy usage units', match: :first)
      Measurements::MEASUREMENT_OPTIONS.values.each { |energy_description| expect(page.has_content?(energy_description.capitalize)).to be true }
      expect(find('#measurement_kwh').selected?).to be true
      expect(find('#measurement_co2').selected?).to be false
    end
  end

  def stub_out_the_aggregation_etc
    allow_any_instance_of(School).to receive(:fuel_types_for_analysis).and_return(:electric_only)
    allow_any_instance_of(SchoolAggregation).to receive(:aggregate_school).with(school).and_return(school)
    allow_any_instance_of(ChartData).to receive(:data).and_return([])
  end
end

