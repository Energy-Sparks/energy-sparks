require 'rails_helper'

describe "downloads", type: :system do

  let(:school_name)               { 'Active school'}
  let!(:school)                   { create_active_school(name: school_name)}
  let!(:teacher)                  { create(:staff, school: school)}
  let(:mpan)                      { 1234567890123 }
  let!(:meter)                    { create(:electricity_meter_with_reading, name: 'Electricity meter', school: school, mpan_mprn: mpan ) }


  before(:each) do
    sign_in(teacher)
    visit root_path
    click_on 'Download your data'
    expect(page).to have_content("Downloads for #{school.name}")
    expect(page).to have_content(mpan)
  end

  it 'allows a full download of data' do
    click_on 'Download AMR data for all meters combined'

    header = page.response_headers['Content-Disposition']
    expect(header).to match /^attachment/
    expect(header).to match /school-amr-readings-#{school.name.parameterize}.csv$/

    # Then check the content
    meter.amr_validated_readings.each do |record|
      expect(page.source).to have_content School::MetersController::CSV_HEADER
      expect(page).to have_content amr_validated_reading_to_s(meter.amr_validated_readings.first)
    end
  end

  it 'allows a download of CSV for a meter' do
    click_on mpan.to_s

    # Make sure the page is a CSV
    header = page.response_headers['Content-Disposition']
    expect(header).to match /^attachment/
    expect(header).to match /filename=\"meter-amr-readings-#{meter.mpan_mprn}.csv\"/

    # Then check the content
    meter.amr_validated_readings.each do |record|
      expect(page.source).to have_content Schools::MetersController::SINGLE_METER_CSV_HEADER
      expect(page).to have_content amr_validated_reading_to_s(meter.amr_validated_readings.first)
    end
  end
end
