# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'manual readings' do
  let(:school) { create(:school) }

  before do
    travel_to(Date.new(2025, 8, 15))
    Flipper.enable(:manual_readings)
    sign_in(create(:school_admin, school:))
  end

  def form_inputs(values: false)
    all('form.edit_school .row')[1..]
      .map { |row| row.all('input', visible: false).map { |input| values ? input.value : input } }
  end

  def form_input_values
    form_inputs(values: true)
  end

  def complete_form(single: false, with: '5', last: false)
    inputs = all('form.edit_school input[type="text"]')
    if last
      inputs = [inputs.last]
    elsif single
      inputs = [inputs.first]
    end
    inputs.each { |input| input.fill_in(with:) }
    click_on 'Save'
  end

  def expected_input_values(year, month, months, extra = nil)
    values = (0..months).map { |i| (Date.new(year, month) + i.months).to_s }
    extra.nil? ? values : values.map { |value| [value] + extra }
  end

  def actual_manual_readings
    school.manual_readings.order(:month).pluck(:month, :electricity, :gas)
  end

  def create_target(start_date)
    create(
      :school_target, :with_monthly_consumption,
      start_date:,
      school:,
      consumption: { electricity: { previous_missing: [true, *[false] * 11],
                                    previous_consumption: [nil, *[1021] * 11] },
                     gas: { current_missing: [false, true, *[false] * 10],
                            previous_missing: [true, *[false] * 11],
                            previous_consumption: [nil, *[1022] * 11] } }
    )
  end

  context 'with an old target' do
    before do
      create_target(1.year.ago)
      visit school_manual_readings_path(school)
    end

    it 'has the correct inputs' do
      expect(form_input_values).to eq([['2023-08-01', nil, nil],
                                       *expected_input_values(2023, 9, 10, %w[1021 1022]),
                                       %w[2024-08-01 1010 1010],
                                       ['2024-09-01', '1010', nil],
                                       *expected_input_values(2024, 10, 8, %w[1010 1010])])
    end

    it 'saves the correct readings' do
      complete_form
      expect(actual_manual_readings).to eq([[Date.new(2023, 8), 5, 5], [Date.new(2024, 9), nil, 5]])
    end
  end

  context 'with a new target' do
    before do
      create_target(Date.current.beginning_of_month)
      visit school_manual_readings_path(school)
    end

    it 'display only past months' do
      expect(form_input_values).to eq([['2024-08-01', nil, nil], *expected_input_values(2024, 9, 9, %w[1021 1022])])
    end

    it 'saves the correct readings' do
      complete_form
      expect(actual_manual_readings).to eq([[Date.new(2024, 8), 5, 5]])
    end
  end

  context 'with a complete target' do
    before do
      create(:school_target, :with_monthly_consumption, school:)
      visit school_manual_readings_path(school)
    end

    it 'shows the enough data message' do
      expect(page).to \
        have_content("We have enough data from your meters so you don't need to enter any readings manually.")
    end
  end

  context 'with electricity only' do
    before { visit school_manual_readings_path(school) }

    it 'shows only electricity inputs on the form' do
      expect(form_input_values).to eq(expected_input_values(2024, 7, 11, [nil]))
    end

    it 'saves the correct readings' do
      complete_form
      expect(actual_manual_readings).to eq((0..11).map { |i| [Date.new(2024, 7) + i.months, 5, nil] })
    end

    it 'saves a single reading' do
      complete_form(single: true)
      expect(actual_manual_readings).to eq([[Date.new(2024, 7), 5, nil]])
    end
  end

  shared_examples 'and gas enabled' do
    it 'shows the gas inputs' do
      expect(form_input_values).to eq(expected_input_values(2024, 7, 11, [nil, nil]))
    end

    it 'saves the correct readings' do
      complete_form
      expect(actual_manual_readings).to eq((0..11).map { |i| [Date.new(2024, 7) + i.months, 5, 5] })
    end
  end

  context 'with gas heating enabled' do
    before do
      school.update!(heating_gas: true)
      visit school_manual_readings_path(school)
    end

    include_examples 'and gas enabled'
  end

  context 'with a gas fuel configuration' do
    before do
      school.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_gas: true))
      visit school_manual_readings_path(school)
    end

    include_examples 'and gas enabled'
  end

  context 'with existing manual readings' do
    before do
      school.manual_readings.create!(month: Date.new(2025, 7), electricity: 1000)
      visit school_manual_readings_path(school)
    end

    it 'shows the existing reading on the form' do
      expect(form_input_values.last).to eq(['2025-07-01', '1000.0'])
    end

    it 'saves the correct readings' do
      complete_form(last: true)
      expect(actual_manual_readings).to eq([[Date.new(2025, 7), 5, nil]])
    end

    it 'removes a cleared reading' do
      complete_form(last: true, with: '')
      expect(actual_manual_readings).to eq([])
    end
  end

  context 'with meter data' do
    let(:school) { create(:school, :with_basic_configuration_single_meter_and_tariffs) }

    before { visit school_manual_readings_path(school) }

    it 'shows the existing meter data in the form inputs' do
      expect(form_input_values).to eq(expected_input_values(2024, 7, 11).zip(
                                        [nil, nil] +
                                          %w[720.0 744.0 720.0 744.0 744.0 672.0 744.0 720.0 744.0 720.0],
                                        Array.new(12, nil)
                                      ))
    end

    it 'updates correctly', :aggregate_failures do
      complete_form(last: true)
      expect(actual_manual_readings).to eq([[Date.new(2025, 6, 1), nil, 5]])
      expect(form_input_values.last).to eq(%w[2025-06-01 720.0 5.0])
      complete_form(last: true, with: '6')
      expect(actual_manual_readings).to eq([[Date.new(2025, 6, 1), nil, 6]])
    end
  end

  context 'with meter data and readings' do
    let(:school) { create(:school, :with_basic_configuration_single_meter_and_tariffs) }

    before do
      school.manual_readings.create!(month: Date.new(2024, 9), electricity: 1000)
      visit school_manual_readings_path(school)
    end

    it 'displays manual readings over calculated values' do
      expect(form_input_values[2]).to eq(['2024-09-01', '1000.0', nil])
    end

    it 'allows changing the manual reading' do
      form_inputs[2][1].fill_in(with: 1001)
      click_on 'Save'
      expect(actual_manual_readings).to eq([[Date.new(2024, 9), 1001, nil]])
    end
  end

  context 'with enough meter data' do
    let(:school) do
      create(:school, :with_basic_configuration_single_meter_and_tariffs, :with_fuel_configuration,
              has_gas: false, reading_start_date: 14.months.ago.to_date)
    end

    before { visit school_manual_readings_path(school) }

    it 'shows the enough data message' do
      expect(page).to \
        have_content("We have enough data from your meters so you don't need to enter any readings manually.")
    end
  end

  it 'validates invalid readings' do
    visit school_manual_readings_path(school)
    complete_form(single: true, with: 'a')
    expect(page).to have_content(['July 2024', 'is not a number'].join("\n"))
  end
end
