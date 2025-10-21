# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'manual readings' do
  let(:school) { create(:school) }

  before do
    travel_to(Date.new(2025, 8, 15))
    Flipper.enable(:manual_readings)
    sign_in(create(:school_admin, school:))
  end

  def form_input_values
    all('form.edit_school .row').map { |row| row.all('input', visible: false).map(&:value) }
  end

  def complete_form(single: false, with: '5', last: false)
    inputs = all('form.edit_school input[type="text"]')
    if last
      inputs.last.fill_in(with:)
    elsif single
      inputs.first.fill_in(with:)
    else
      inputs.each { |input| input.fill_in(with:) }
    end
    click_on 'Save'
  end

  def month_input_values(year, month, months, extra = nil)
    values = (0..months).map { |i| (Date.new(year, month) + i.months).to_s }
    extra.nil? ? values : values.map { |value| [value] + extra }
  end

  context 'with a target' do
    def create_target(start_date)
      create(
        :school_target, :with_monthly_consumption,
        start_date:,
        school:,
        consumption: { electricity: { missing: [true, *[false] * 11], previous_consumption: [nil, *[1021] * 11] },
                       gas: { missing: [true, true, *[false] * 10], previous_consumption: [nil, *[1022] * 11] } }
      )
    end

    it 'accepts manual readings when missing current and previous months' do
      create_target(1.year.ago)
      visit school_manual_readings_path(school)
      expect(form_input_values).to eq([[],
                                       ['2023-08-01', nil, nil],
                                       *month_input_values(2023, 9, 10, %w[1021 1022]),
                                       %w[2024-08-01 1010 1010],
                                       ['2024-09-01', '1010', nil],
                                       *month_input_values(2024, 10, 9, %w[1010 1010])])
      complete_form
      expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to \
        eq([[Date.new(2023, 8), 5, 5],
            [Date.new(2024, 9), nil, 5]])
    end

    it 'displays only past months with a new target' do
      create_target(Date.current.beginning_of_month)
      visit school_manual_readings_path(school)
      expect(form_input_values).to eq([[],
                                       ['2024-08-01', nil, nil],
                                       *month_input_values(2024, 9, 10, %w[1021 1022])])
      complete_form
      expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to eq([[Date.new(2024, 8), 5, 5]])
    end

    it 'has enough data - target complete' do
      create(:school_target, :with_monthly_consumption, school:)
      visit school_manual_readings_path(school)
      expect(page).to \
        have_content("We have enough data from your meters so you don't need to enter any readings manually.")
    end
  end

  context 'without a target' do
    it 'has electricity only' do
      visit school_manual_readings_path(school)
      expect(form_input_values).to eq([[], *month_input_values(2024, 7, 12, [nil])])
      complete_form
      expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to \
        eq((0..12).map { |i| [Date.new(2024, 7) + i.months, 5, nil] })
    end

    it 'with gas' do
      school.update!(heating_gas: true)
      visit school_manual_readings_path(school)
      expect(form_input_values).to eq([[], *month_input_values(2024, 7, 12, [nil, nil])])
      complete_form
      expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to \
        eq((0..12).map { |i| [Date.new(2024, 7) + i.months, 5, 5] })
    end

    it 'with a gas fuel configuration' do
      school.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_gas: true))
      visit school_manual_readings_path(school)
      expect(form_input_values).to eq([[], *month_input_values(2024, 7, 12, [nil, nil])])
      complete_form
      expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to \
        eq((0..12).map { |i| [Date.new(2024, 7) + i.months, 5, 5] })
    end

    it 'accept single input' do
      visit school_manual_readings_path(school)
      complete_form(single: true)
      expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to \
        eq([[Date.new(2024, 7), 5, nil]])
    end

    it 'updates existing' do
      school.manual_readings.create!(month: Date.new(2025, 7), electricity: 1000)
      visit school_manual_readings_path(school)
      expect(form_input_values.last).to eq(['2025-07-01', '1000.0', '0', '1'])
      complete_form(last: true)
      expect(school.manual_readings.order(:month).pluck(:month, :electricity, :gas)).to \
        eq([[Date.new(2025, 7), 5, nil]])
    end

    context 'with data' do
      let(:school) { create(:school, :with_basic_configuration_single_meter_and_tariffs) }

      it 'already has data' do
        visit school_manual_readings_path(school)
        expect(form_input_values).to eq([[],
                                         *month_input_values(2024, 7, 12).zip(
                                           [nil, nil, '720.0', '744.0', '720.0', '744.0', '744.0', '672.0', '744.0',
                                            '720.0', '744.0', '720.0', '744.0'],
                                           Array.new(13, nil)
                                         )])
      end
    end

    context 'with enough data' do
      let(:school) do
        create(:school, :with_basic_configuration_single_meter_and_tariffs, reading_start_date: 14.months.ago.to_date)
      end

      it 'has enough data' do
        school.update!(configuration: school.configuration.tap { |c| c[:fuel_configuration]['has_gas'] = false })
        visit school_manual_readings_path(school)
        expect(page).to \
          have_content("We have enough data from your meters so you don't need to enter any readings manually.")
      end
    end
  end

  it 'validates invalid readings' do
    visit school_manual_readings_path(school)
    complete_form(single: true, with: 'a')
    expect(page).to have_content(['July 2024', 'is not a number'].join("\n"))
  end
end
