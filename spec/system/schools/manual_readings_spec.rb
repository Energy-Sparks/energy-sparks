# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'manual readings' do
  let(:school) { create(:school, :with_fuel_configuration, :with_meter_dates) }

  before do
    travel_to(Date.new(2025, 8, 15))
    Flipper.enable(:manual_readings)
    sign_in(create(:school_admin, school:))
  end

  it 'is on the manage school menu' do
    visit school_path(school)
    click_on 'Manage School'
    click_on 'Manual readings'
    expect(page).to have_current_path("/schools/#{school.slug}/manual_readings")
  end

  it 'links to new target when no target set' do
    visit school_manual_readings_path(school)
    expect(page).to have_content('Please set a target so your missing readings can be calcuated.')
  end

  it 'has enough data' do
    target = create(:school_target, school:)
    start_date = target.start_date.prev_year.beginning_of_month
    school.configuration.update!(aggregate_meter_dates: { gas: { start_date: }, electricity: { start_date: } })
    visit school_manual_readings_path(school)
    expect(page).to \
      have_content("We have enough data from your meters so you don't need to enter any readings manually.")
  end

  it 'allows creating readings when required' do
    target = create(:school_target, school:)
    start_date = target.start_date.advance(months: -10)
    school.configuration.update!(aggregate_meter_dates: { gas: { start_date: },
                                                          electricity: { start_date: start_date.advance(months: -1) } })
    visit school_manual_readings_path(school)
    expect(page).to have_content(
      ['Date', 'Electricity', 'Gas', 'August 2024', 'Remove', 'September 2024', '-', 'Remove'].join("\n")
    )
    all('input[type="number"]').each { |input| input.fill_in with: '5' }
    click_on 'Save'
    expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to \
      eq([[Date.new(2024, 8, 1), 5, 5],
          [Date.new(2024, 9, 1), nil, 5]])
  end

  it 'shows the correct fuels' do
    fuel_configuration = school.configuration.fuel_configuration
    fuel_configuration.instance_variable_set(:@has_gas, false)
    school.configuration.update!(fuel_configuration:)
    visit school_manual_readings_path(school)
    expect(page).to have_content("Date\nElectricity\nJuly 2023\n")
  end

  it 'is missing some current year consumption' do
    1/0
  end
end
