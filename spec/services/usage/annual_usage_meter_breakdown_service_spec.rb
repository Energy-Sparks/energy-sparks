# frozen_string_literal: true

require 'rails_helper'

describe Usage::AnnualUsageMeterBreakdownService, type: :service do
  let(:asof_date) { nil }
  let(:fuel_type) { :electricity }
  let(:meter_collection) { load_unvalidated_meter_collection(school: 'acme-academy') }
  let(:service) { described_class.new(meter_collection, fuel_type, asof_date) }

  describe '#calculate_breakdown' do
    def format_unit(unit, val)
      FormatUnit.format(unit, val, :html, true, true)
    end

    context 'with electricity' do
      context 'with two years data' do
        it 'calculates the expected values' do
          usage_breakdown = service.calculate_breakdown

          expect(usage_breakdown.start_date).to eq(Date.new(2022, 10, 9))
          expect(usage_breakdown.end_date).to eq(Date.new(2023, 10, 7))

          # Old Building
          # mpan 1591058886735
          percent = usage_breakdown.annual_percent_change(1_591_058_886_735)
          expect(format_unit(:relative_percent, percent)).to eq '+0.21&percnt;'
          old_building = usage_breakdown.usage(1_591_058_886_735)
          expect(format_unit(:kwh, old_building.kwh)).to eq '99,000'
          expect(format_unit(:co2, old_building.co2)).to eq '17,000'
          expect(format_unit(:£, old_building.£)).to eq '&pound;15,000'
          expect(format_unit(:percent, old_building.percent)).to eq '24&percnt;'

          # New Building
          # mpan, 1580001320420
          percent = usage_breakdown.annual_percent_change(1_580_001_320_420)
          expect(format_unit(:relative_percent, percent)).to eq '-14&percnt;'
          new_building = usage_breakdown.usage(1_580_001_320_420)
          expect(format_unit(:kwh, new_building.kwh)).to eq '310,000'
          expect(format_unit(:co2, new_building.co2)).to eq '52,000'
          expect(format_unit(:£, new_building.£)).to eq '&pound;47,000'
          expect(format_unit(:percent, new_building.percent)).to eq '76&percnt;'

          # Total
          percent = usage_breakdown.total_annual_percent_change
          expect(format_unit(:relative_percent, percent)).to eq '-11&percnt;'
          usage_breakdown.total_usage
          expect(format_unit(:kwh, usage_breakdown.total_usage.kwh)).to eq '410,000'
          expect(format_unit(:co2, usage_breakdown.total_usage.co2)).to eq '68,000'
          expect(format_unit(:£, usage_breakdown.total_usage.£)).to eq '&pound;61,000'
          expect(format_unit(:percent, usage_breakdown.total_usage.percent)).to eq '100&percnt;'
        end
      end
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      context 'with two years data' do
        it 'calculates the expected values' do
          usage_breakdown = service.calculate_breakdown
          expect(usage_breakdown.start_date).to eq(Date.new(2022, 10, 9))
          expect(usage_breakdown.end_date).to eq(Date.new(2023, 10, 7))

          # Lodge
          percent = usage_breakdown.annual_percent_change(10_307_706)
          expect(format_unit(:relative_percent, percent)).to eq '-77&percnt;'
          meter = usage_breakdown.usage(10_307_706)
          expect(format_unit(:kwh, meter.kwh)).to eq '3,400'
          expect(format_unit(:£, meter.£)).to eq '&pound;100'
          expect(format_unit(:percent, meter.percent)).to eq '0.63&percnt;'

          # Art Block
          percent = usage_breakdown.annual_percent_change(10_308_203)
          expect(format_unit(:relative_percent, percent)).to eq '-10&percnt;'
          meter = usage_breakdown.usage(10_308_203)
          expect(format_unit(:kwh, meter.kwh)).to eq '56,000'
          expect(format_unit(:£, meter.£)).to eq '&pound;1,700'
          expect(format_unit(:percent, meter.percent)).to eq '10&percnt;'

          # Total
          percent = usage_breakdown.total_annual_percent_change
          expect(format_unit(:relative_percent, percent)).to eq '-8&percnt;'
          usage_breakdown.total_usage
          expect(format_unit(:kwh, usage_breakdown.total_usage.kwh)).to eq '550,000'
          expect(format_unit(:£, usage_breakdown.total_usage.£)).to eq '&pound;16,000'
          expect(format_unit(:percent, usage_breakdown.total_usage.percent)).to eq '100&percnt;'
        end
      end
    end
  end
end
