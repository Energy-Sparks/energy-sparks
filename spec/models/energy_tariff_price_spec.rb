# frozen_string_literal: true

require 'rails_helper'

describe EnergyTariffPrice do
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:end_time) }
  it { is_expected.to validate_presence_of(:units) }
  it { is_expected.to validate_numericality_of(:value).is_greater_than(EnergyTariffPrice::MINIMUM_VALUE).is_less_than(EnergyTariffPrice::MAXIMUM_VALUE) }

  describe '#time_duration' do
    it 'calculates the time duration in minutes between the start and end date' do
      energy_tariff_price = described_class.new(start_time: '2000-01-01 00:00:00', end_time: '2000-01-01 00:30:00')
      expect(energy_tariff_price.time_duration).to eq(30.0) # 30 minutes
      energy_tariff_price.end_time = '2000-01-01 01:00:00'
      expect(energy_tariff_price.time_duration).to eq(60.0) # 1 hour
      energy_tariff_price.end_time = '2000-01-01 01:30:00'
      expect(energy_tariff_price.time_duration).to eq(90.0) # 1 hour 30 mins
      energy_tariff_price.end_time = '2000-01-01 02:00:00'
      expect(energy_tariff_price.time_duration).to eq(2 * 60) # 2 hours
      energy_tariff_price.end_time = '2000-01-01 12:00:00'
      expect(energy_tariff_price.time_duration).to eq(12 * 60) # 12 hours
      energy_tariff_price.end_time = '2000-01-01 23:30:00'
      expect(energy_tariff_price.time_duration).to eq((23 * 60) + 30) # 23 hours 30 minutes
      energy_tariff_price.start_time = '2000-01-01 23:30:00'
      energy_tariff_price.end_time = '2000-01-01 07:30:00'
      expect(energy_tariff_price.time_duration).to eq(8 * 60) # 8 hours
    end
  end

  describe '#total_minutes' do
    it 'returns the sum of all minutes in a collection of energy tariff prices' do
      energy_tariff = EnergyTariff.create!(name: 'A new tariff', tariff_holder: create(:school),
                                           tariff_type: 'flat_rate')
      described_class.delete_all
      described_class.create!(start_time: '2000-01-01 00:00:00', end_time: '2000-01-01 07:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 07:00:00', end_time: '2000-01-01 00:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq(24 * 60) # 24 hours

      described_class.delete_all
      described_class.create!(start_time: '2000-01-01 00:00:00', end_time: '2000-01-01 05:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 07:00:00', end_time: '2000-01-01 00:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq(22 * 60) # 22 hours

      described_class.delete_all
      described_class.create!(start_time: '2000-01-01 00:030:00', end_time: '2000-01-01 05:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 07:00:00', end_time: '2000-01-01 00:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq((21 * 60) + 30) # 21 hours 30 minutes

      described_class.delete_all
      described_class.create!(start_time: '2000-01-01 01:30:00', end_time: '2000-01-01 05:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 05:00:00', end_time: '2000-01-01 01:30:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq(24 * 60) # 24 hours
    end
  end

  describe '#invalid_prices?' do
    it 'returns true if any value is nil or zero' do
      energy_tariff = EnergyTariff.create!(name: 'A new tariff', tariff_holder: create(:school),
                                           tariff_type: 'differential')
      described_class.delete_all
      energy_tariff_price_1 = described_class.create!(start_time: '2000-01-01 00:00:00',
                                                      end_time: '2000-01-01 05:00:00', units: 'kwh', energy_tariff: energy_tariff)
      energy_tariff_price_2 = described_class.create!(start_time: '2000-01-01 07:00:00',
                                                      end_time: '2000-01-01 00:00:00', units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.reload.energy_tariff_prices.map(&:value)).to contain_exactly(nil, nil)
      expect(energy_tariff.energy_tariff_prices.invalid_prices?).to be(true)
      energy_tariff_price_1.update(value: 0.1)
      expect(energy_tariff.reload.energy_tariff_prices.map(&:value)).to contain_exactly(0.1, nil)
      expect(energy_tariff.energy_tariff_prices.invalid_prices?).to be(true)
      energy_tariff_price_2.update(value: 0.1)
      expect(energy_tariff.reload.energy_tariff_prices.map(&:value)).to contain_exactly(0.1, 0.1)
      expect(energy_tariff.energy_tariff_prices.invalid_prices?).to be(false)
    end
  end

  describe '#possible_time_range_gaps' do
    it 'returns true if any value is nil or zero' do
      energy_tariff = EnergyTariff.create!(name: 'A new tariff', tariff_holder: create(:school),
                                           tariff_type: 'differential')
      described_class.delete_all
      described_class.create!(start_time: '2000-01-01 02:00:00', end_time: '2000-01-01 03:30:00', units: 'kwh',
                              energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 14:30:00', end_time: '2000-01-01 16:30:00', units: 'kwh',
                              energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 16:30:00', end_time: '2000-01-01 17:30:00', units: 'kwh',
                              energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 19:00:00', end_time: '2000-01-01 20:30:00', units: 'kwh',
                              energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 21:00:00', end_time: '2000-01-01 22:30:00', units: 'kwh',
                              energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.possible_time_range_gaps).to contain_exactly(
        DateTime.parse('2000-01-01 03:30:00 UTC')..DateTime.parse('2000-01-01 14:30:00 UTC'), DateTime.parse('2000-01-01 17:30:00 UTC')..DateTime.parse('2000-01-01 19:00:00 UTC'), DateTime.parse('2000-01-01 20:30:00 UTC')..DateTime.parse('2000-01-01 21:00:00 UTC'), DateTime.parse('2000-01-01 22:30:00 UTC')..DateTime.parse('2000-01-01 02:00:00 UTC')
      )
    end
  end

  describe '#complete?' do
    it 'returns if the sum of all minutes in a collection of energy tariff prices adds up to 24 hours (1440 minutes) and can be considered complete' do
      energy_tariff = EnergyTariff.create!(name: 'A new tariff', tariff_holder: create(:school),
                                           tariff_type: 'differential')
      described_class.delete_all
      described_class.create!(start_time: '2000-01-01 00:00:00', end_time: '2000-01-01 05:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 07:00:00', end_time: '2000-01-01 00:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to be(false) # 22 hours

      described_class.delete_all
      energy_tariff.reload
      described_class.create!(start_time: '2000-01-01 00:030:00', end_time: '2000-01-01 05:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 07:00:00', end_time: '2000-01-01 00:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to be(false) # 21 hours 30 minutes

      described_class.delete_all
      energy_tariff.reload
      described_class.create!(start_time: '2000-01-01 01:30:00', end_time: '2000-01-01 05:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 05:00:00', end_time: '2000-01-01 01:30:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to be(true) # 24 hours

      described_class.delete_all
      energy_tariff.reload
      described_class.create!(start_time: '2000-01-01 03:30:00', end_time: '2000-01-01 05:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 05:00:00', end_time: '2000-01-01 22:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 22:00:00', end_time: '2000-01-01 02:30:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 02:30:00', end_time: '2000-01-01 03:30:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to be(true) # 24 hours

      described_class.delete_all
      energy_tariff.reload
      described_class.create!(start_time: '2000-01-01 00:00:00', end_time: '2000-01-01 07:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      described_class.create!(start_time: '2000-01-01 07:00:00', end_time: '2000-01-01 00:00:00', value: 0.1,
                              units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to be(true) # 24 hours
    end
  end
end
