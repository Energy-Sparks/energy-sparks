# frozen_string_literal: true

require 'spec_helper'

describe Corrections::Rescaler, type: :service do
  let(:mpan_mprn)    { '1' }
  let(:kwh_data_x48) { Array.new(48, 0.1) }
  let(:amr_data_end_date) { Date.new(2023, 1, 31) }
  let(:amr_data) do
    build(:amr_data, :with_days, day_count: 31, end_date: amr_data_end_date, kwh_data_x48: kwh_data_x48)
  end

  let(:start_date)   { Date.new(2023, 1, 1) }
  let(:end_date)     { Date.new(2023, 1, 10) }
  let(:scale)        { 10.0 }

  let(:service)      { described_class.new(amr_data, mpan_mprn) }

  let(:results)      { service.perform(start_date: start_date, end_date: end_date, scale: scale) }

  it 'rescales the data' do
    (start_date..end_date).each do |date|
      expect(results.days_kwh_x48(date)).to eq Array.new(48, 1.0)
    end
    first_date_outside_correction_range = end_date + 1
    expect(results.days_kwh_x48(first_date_outside_correction_range)).to eq Array.new(48, 0.1)
    expect(results.end_date).to eq amr_data_end_date
  end

  it 'annotates the corrected data' do
    expect(results.days_amr_data(start_date)).not_to be_nil
    expect(results.meter_id(start_date)).to eq mpan_mprn
    expect(results.substitution_type(start_date)).to eq 'S31M'
    expect(results.substitution_date(start_date)).to eq nil
  end

  describe 'with earlier correction start date' do
    let(:start_date) { Date.new(2023, 1, 1) }

    it 'uses amr data start date' do
      (start_date..end_date).each do |date|
        expect(results.days_kwh_x48(date)).to eq Array.new(48, 1.0)
      end
      expect(results.start_date).to eq Date.new(2023, 1, 1)
    end
  end

  describe 'with nil correction start date' do
    let(:start_date) { nil }

    it 'uses amr data start date' do
      expect(results.start_date).to eq Date.new(2023, 1, 1)
      (results.start_date..end_date).each do |date|
        expect(results.days_kwh_x48(date)).to eq Array.new(48, 1.0)
      end
    end
  end

  describe 'with later correction end date' do
    let(:end_date) { Date.new(2023, 3, 1) }

    it 'uses amr data end date' do
      (start_date..amr_data_end_date).each do |date|
        expect(results.days_kwh_x48(date)).to eq Array.new(48, 1.0)
      end
      expect(results.end_date).to eq Date.new(2023, 1, 31)
    end
  end

  describe 'with nil correction end date' do
    let(:end_date)   { nil }

    it 'uses amr data end date' do
      (start_date..amr_data_end_date).each do |date|
        expect(results.days_kwh_x48(date)).to eq Array.new(48, 1.0)
      end
      expect(results.end_date).to eq Date.new(2023, 1, 31)
    end
  end
end
