require 'rails_helper'

RSpec.describe 'meter reports', :amr_validated_readings, type: :system do
  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create(:school, :with_school_group, name: school_name)}
  let!(:admin)        { create(:admin) }
  let!(:meter)        { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school) }

  before do
    sign_in(admin)
    visit root_path
  end

  context 'when a meter has readings' do
    before do
      visit admin_school_group_meter_report_path(school.school_group)
    end

    it 'includes school and meters' do
      expect(page.has_content?(school.name)).to be true
      expect(page.has_content?(meter.mpan_mprn)).to be true
    end

    it 'links to a rich calendar view', js: true do
      click_on(meter.name.to_s)
      expect(page).to have_content 'This report provides a calendar view of the validated meter readings'
      expect(page).to have_content 'January'
    end

    it 'includes sub nav on meter readings page' do
      click_on('Electricity meter')
      expect(page).to have_link('Manage School')
    end
  end

  context 'when there are gaps in the meter readings' do
    let(:base_date) { Time.zone.today - 1.year }

    before do
      create(:amr_validated_reading, meter: meter, reading_date: base_date, status: 'ORIG')
      15.times do |idx|
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 1 + idx.days, status: 'NOT_ORIG')
      end
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 17, status: 'ORIG')
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 18, status: 'NOT_ORIG')
      visit admin_school_group_meter_report_path(school.school_group)
    end

    it 'shows count of modified dates and gaps' do
      expect(page).to have_content 'Large gaps (last 2 years)'
      expect(page).to have_content 'Modified readings (last 2 years)'

      within '.gappy-dates' do
        expect(page).to have_content "15 days (#{(base_date + 1.day).to_fs(:es_short)} to #{(base_date + 15.days).to_fs(:es_short)})"
      end

      within '.modified-dates' do
        expect(page).to have_content '16'
      end
    end
  end
end
