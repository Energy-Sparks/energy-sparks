# frozen_string_literal: true

require 'rails_helper'

describe Aggregation::SolarPvPanels, type: :service do # rubocop:todo RSpec/MultipleMemoizedHelpers
  # ranges for amr data
  let(:start_date)         { Date.new(2023, 1, 1) }
  let(:end_date)           { Date.new(2023, 1, 31) }

  # unoccupied + occupied days
  let(:sunday)             { start_date }
  let(:monday)             { Date.new(2023, 1, 2) }

  let(:solar_pv_installation_date)  { start_date }
  let(:kwp)                         { 10.0 }
  let(:meter_attributes)   { [{ start_date: solar_pv_installation_date, kwp: kwp }] }

  # fake yield data from Sheffield
  let(:solar_yield)        do
    Array.new(10, 0.0) + Array.new(10, 0.25) + Array.new(8, 0.5) + Array.new(10, 0.25) + Array.new(10, 0.0)
  end

  let(:solar_pv) do
    build(:solar_pv, :with_days,
          start_date: start_date,
          end_date: end_date,
          data_x48: solar_yield)
  end

  let(:pv_meter_map)       { SolarMeterMap.new }

  let(:is_holiday)         { false }
  let(:holidays)           { instance_double(Holidays, holiday?: is_holiday) }

  let(:meter_collection)   { build(:meter_collection, holidays: holidays) }

  let(:kwh_data_x48)       do
    Array.new(10, 0.1) + Array.new(10, 0.005) + Array.new(8, 0.4) + Array.new(10, 0.25) + Array.new(10, 0.01)
  end

  let(:meter) do
    build(:meter,
          meter_collection: meter_collection,
          amr_data: build(:amr_data, :with_days, day_count: 31,
                                                 end_date: Date.new(2023, 1, 31), kwh_data_x48: kwh_data_x48))
  end

  let(:service) { described_class.new(meter_attributes, solar_pv) }

  before do
    pv_meter_map[:mains_consume] = meter
  end

  context 'when generating synthetic data' do # rubocop:todo RSpec/MultipleMemoizedHelpers
    before do
      service.process(pv_meter_map, meter_collection)
    end

    it 'populates the PV map with extra meters of the right type' do
      expect(pv_meter_map[:generation]).not_to be_nil
      expect(pv_meter_map[:generation].fuel_type).to eq :solar_pv
      expect(pv_meter_map.number_of_generation_meters).to eq 1

      expect(pv_meter_map[:export]).not_to be_nil
      expect(pv_meter_map[:export].fuel_type).to eq :exported_solar_pv

      expect(pv_meter_map[:self_consume]).not_to be_nil
      expect(pv_meter_map[:self_consume].fuel_type).to eq :solar_pv
    end

    it 'produces synthetic meters with right date ranges' do
      %i[export self_consume generation].each do |meter_type|
        unless pv_meter_map[meter_type].nil?
          expect(pv_meter_map[meter_type].amr_data.start_date).to eq start_date
          expect(pv_meter_map[meter_type].amr_data.end_date).to eq end_date
        end
      end
    end

    it 'calculates generation data' do
      # expected data is pv_yield * (capacity / 2.0) == solar_pv_yield * (kwp / 2.0)
      expect(pv_meter_map[:generation].amr_data.days_kwh_x48(sunday)).to eq [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                                                             0.0, 0.0, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 1.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    end

    it 'calculates export data' do
      days_data = pv_meter_map[:export].amr_data.days_kwh_x48(sunday)
      # should be exporting from periods 11-37 on the sunday based on AMR and solar data
      expect(days_data[11..37].all? { |hh| hh < 0.0 }).to be true

      days_data = pv_meter_map[:export].amr_data.days_kwh_x48(monday)
      # should not be exporting on the monday as school is occupied
      expect(days_data).to eq Array.new(48, 0.0)
    end

    it 'calculates self consumption data' do
      # puts "GENERATION"
      # p pv_meter_map[:generation].amr_data.days_kwh_x48(sunday)
      # puts days_data.inspect

      # puts "EXPORT"
      # p pv_meter_map[:export].amr_data.days_kwh_x48(sunday)
      # puts days_data.inspect

      # puts "SELF CONSUME"
      days_data = pv_meter_map[:self_consume].amr_data.days_kwh_x48(sunday)

      # should be consuming from periods 10-19 on the sunday based on AMR and solar data
      # the period of Array.new(10, 0.005) is lowering than yesterdays baseload, so
      # there will be self-consumption from solar generation
      expect(days_data[10..19].all? { |hh| hh > 0.0 }).to be true

      days_data = pv_meter_map[:self_consume].amr_data.days_kwh_x48(monday)
      # should be consuming all of the generation on the monday when occupied
      # TODO this could be better: could check that we're consuming ~pv output
      expect(days_data[11..37].all? { |hh| hh > 0.0 }).to be true
    end
  end

  # Cross check values against spreadsheet with revised logic.
  context 'with analysis-cross-check' do # rubocop:todo RSpec/MultipleMemoizedHelpers
    let(:solar_pv_installation_date)  { Date.new(2022, 6, 8) }
    let(:kwp)                         { 24.0 }

    def run(date)
      # mains consumption
      reading = build(:one_day_amr_reading, date: date,
                                            kwh_data_x48: [3.4, 3.5, 3.5, 3.9, 3.6, 3.3, 3.7, 3.4, 3.2, 3.6, 3.1, 3, 2.3, 1.00, 0.2, 0.1, 0, 0, 0, 0.4, 0.3, 0.3, 0.1, 0.1, 0, 0, 0, 0, 0.3, 0, 0.1, 0.1, 1.2, 1.1, 1.3, 2.4, 2.7, 3.5, 3, 3.5, 3.2, 3.7, 3.2, 3.5, 3.6, 3.4, 3.3, 3.6])
      amr_data = AMRData.new('electricity')
      amr_data.add(date, reading)

      meter = build(:meter, meter_collection: meter_collection, amr_data: amr_data)
      pv_meter_map[:mains_consume] = meter

      # generation
      reading = build(:one_day_amr_reading, date: date,
                                            kwh_data_x48: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.12, 0.2973231149, 0.6370898507, 1.208988034, 2.167310171, 3.282425912, 4.346064793, 5.267356951, 5.708955202, 5.81534689, 6.469848986, 7.371458542, 7.772134775, 8.181660764, 8.360750196, 8.511418471, 8.174729226, 8.030584752, 7.403586404, 6.529091392, 6.0378511, 5.208920753, 4.101070153, 3.216020299, 2.146506292, 1.218588399, 0.4695217831, 0.1575868388, 0, 0, 0, 0, 0, 0, 0])
      amr_data = AMRData.new('generation')
      amr_data.add(date, reading)

      meter = build(:meter, meter_collection: meter_collection, amr_data: amr_data)
      pv_meter_map[:generation] = meter

      # This version of the class is for metered generation, so will use the above values
      service = Aggregation::SolarPvPanelsMeteredProduction.new
      allow(service).to receive_messages(yesterday_baseload_kw: 6.88571428571428, unoccupied?: true)

      service.process(pv_meter_map, meter_collection)

      pv_meter_map
    end

    it 'does expected calculations' do
      date = Date.new(2022, 6, 8)

      pv_meter_map = run(date)

      # puts "MAINS"
      # puts pv_meter_map[:mains_consume].amr_data.days_kwh_x48(date).inspect

      # puts "GENERATION"
      # puts pv_meter_map[:generation].amr_data.days_kwh_x48(date).inspect

      # puts "EXPORT"
      # puts pv_meter_map[:export].amr_data.days_kwh_x48(date).inspect

      # compare with result in spreadsheet
      rounded_export = pv_meter_map[:export].amr_data.days_kwh_x48(date).map { |n| n.round(2) }
      expect(rounded_export).to eq [0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
                                    0.00, 0.00, 0.00, -0.90, -1.82, -2.27, -2.37, -3.03, -3.93, -4.33, -4.74, -4.92, -5.07, -4.73, -4.59, -3.96, -3.09, -2.59, -1.77, -0.66, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00]

      # puts "SELF CONSUME"
      # puts pv_meter_map[:self_consume].amr_data.days_kwh_x48(date).inspect

      # compare with rounded result in spreadsheet
      rounded_self_consume = pv_meter_map[:self_consume].amr_data.days_kwh_x48(date).map { |n| n.round(2) }
      expect(rounded_self_consume).to eq([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.12,
                                          0.2973231149, 0.6370898507, 1.208988034, 2.167310171, 3.282425912, 3.113472611, 3.213472611, 3.213472611, 3.413472611, 3.413472611, 3.513472611, 3.513472611, 3.513472611, 3.513472611, 3.213472611, 3.513472611, 3.413472611, 3.413472611, 2.313472611, 2.413472611, 2.213472611, 1.113472611, 0.8134726114, 0.0, 0.5134726114, 0.0, 0.1575868388, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0].map do |n|
                                           n.round(2)
                                         end)
    end
  end

  context 'when overriding existing data' do # rubocop:todo RSpec/MultipleMemoizedHelpers
    it 'should skip days when school is unoccupied'
    it 'should calculate expected export'
    it 'should calculate generation data'
    it 'should calculate self consumption data'
  end
end
