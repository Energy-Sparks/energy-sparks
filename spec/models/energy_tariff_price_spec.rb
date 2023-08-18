require 'rails_helper'

describe EnergyTariffPrice do
  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:end_time) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:units) }
  it { should validate_numericality_of(:value).is_greater_than_or_equal_to(EnergyTariffPrice::MINIMUM_VALUE) }

  describe '#time_duration' do
    it 'calculates the time durstion in minutes between the start and end date' do
      energy_tariff_price = EnergyTariffPrice.new(start_time: "2000-01-01 00:00:00", end_time: "2000-01-01 00:30:00")
      expect(energy_tariff_price.time_duration).to eq(30.0) # 30 minutes
      energy_tariff_price.end_time = "2000-01-01 01:00:00"
      expect(energy_tariff_price.time_duration).to eq(60.0) # 1 hour
      energy_tariff_price.end_time = "2000-01-01 01:30:00"
      expect(energy_tariff_price.time_duration).to eq(90.0) # 1 hour 30 mins
      energy_tariff_price.end_time = "2000-01-01 02:00:00"
      expect(energy_tariff_price.time_duration).to eq(2*60) # 2 hours
      energy_tariff_price.end_time = "2000-01-01 12:00:00"
      expect(energy_tariff_price.time_duration).to eq(12*60) # 12 hours
      energy_tariff_price.end_time = "2000-01-01 23:30:00"
      expect(energy_tariff_price.time_duration).to eq((23*60)+30) # 23 hours 30 minutes
      energy_tariff_price.start_time = "2000-01-01 23:30:00"
      energy_tariff_price.end_time = "2000-01-01 07:30:00"
      expect(energy_tariff_price.time_duration).to eq(8*60) # 8 hours
    end
  end

  describe '#total_minutes' do
    it 'it returns the sum of all minutes in a collection of energy tariff prices' do
      energy_tariff = EnergyTariff.create!(name: 'A new tariff', tariff_holder: create(:school))
      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 00:00:00", end_time: "2000-01-01 07:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 07:00:00", end_time: "2000-01-01 00:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq(24*60) # 24 hours

      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 00:00:00", end_time: "2000-01-01 05:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 07:00:00", end_time: "2000-01-01 00:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq(22*60) # 22 hours

      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 00:030:00", end_time: "2000-01-01 05:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 07:00:00", end_time: "2000-01-01 00:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq(21*60 + 30) # 21 hours 30 minutes

      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 01:30:00", end_time: "2000-01-01 05:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 05:00:00", end_time: "2000-01-01 01:30:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.total_minutes).to eq(24*60) # 24 hours
    end
  end

  describe '#complete?' do
    it 'it returns if the sum of all minutes in a collection of energy tariff prices adds up to 24 hours (1440 minutes) and can be considered complete' do
      energy_tariff = EnergyTariff.create!(name: 'A new tariff', tariff_holder: create(:school))
      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 00:00:00", end_time: "2000-01-01 05:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 07:00:00", end_time: "2000-01-01 00:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to eq(false) # 22 hours

      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 00:030:00", end_time: "2000-01-01 05:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 07:00:00", end_time: "2000-01-01 00:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to eq(false) # 21 hours 30 minutes

      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 01:30:00", end_time: "2000-01-01 05:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 05:00:00", end_time: "2000-01-01 01:30:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to eq(true) # 24 hours

      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 03:30:00", end_time: "2000-01-01 05:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 05:00:00", end_time: "2000-01-01 22:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 22:00:00", end_time: "2000-01-01 02:30:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 02:30:00", end_time: "2000-01-01 03:30:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to eq(true) # 24 hours

      EnergyTariffPrice.delete_all
      EnergyTariffPrice.create!(start_time: "2000-01-01 00:00:00", end_time: "2000-01-01 07:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      EnergyTariffPrice.create!(start_time: "2000-01-01 07:00:00", end_time: "2000-01-01 00:00:00", value: 0, units: 'kwh', energy_tariff: energy_tariff)
      expect(energy_tariff.energy_tariff_prices.complete?).to eq(true) # 24 hours
    end
  end
end
