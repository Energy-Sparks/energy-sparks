require 'rails_helper'
require 'dashboard'

module Amr
  describe AnalyticsTariffFactory do
    let(:meter) { create(:electricity_meter, dcc_meter: true) }
    let(:factory) { Amr::AnalyticsTariffFactory.new(meter) }

    let(:date) { Date.yesterday }

    let!(:standing_charge) { create(:tariff_standing_charge, meter: meter, start_date: date) }

    context 'with no data' do
      it 'returns nil' do
        expect(factory.build).to be_nil
      end
    end

    context 'with differential tariff' do
      let!(:prices) { create(:tariff_price, :with_differential_tariff, meter: meter, tariff_date: date) }

      let(:expected_attributes) do
        [{
           start_date: date,
           end_date: date,
           name: 'Tariff from DCC SMETS2 meter',
           tariff_holder: :meter,
           rates: {
             rate0: {
               from: ::TimeOfDay30mins.new(0, 0),
               to: ::TimeOfDay30mins.new(4, 30),
               per: :kwh,
               rate: 0.1
             },
             rate1: {
               from: ::TimeOfDay30mins.new(5, 0),
               to: ::TimeOfDay30mins.new(14, 30),
               per: :kwh,
               rate: 0.2
             },
             rate2: {
               from: ::TimeOfDay30mins.new(15, 0),
               to: ::TimeOfDay30mins.new(23, 30),
               per: :kwh,
               rate: 0.3
             },
             standing_charge: {
               per: :day,
               rate: standing_charge.value
             }
           },
           type: :differential,
           source: :dcc
         }]
      end

      it 'builds and returns the meter attributes' do
        attributes = factory.build
        expect(attributes).to_not be_nil
        expect(attributes[:accounting_tariff_generic]).to eql(expected_attributes)
      end
    end

    context 'with differential tiered tariff' do
      let!(:prices) { create(:tariff_price, :with_differential_tiered_tariff, meter: meter, tariff_date: date) }

      let(:expected_attributes) do
        [{
          :start_date => date,
          :end_date => date,
          :name => "Tariff from DCC SMETS2 meter",
          tariff_holder: :meter,
          :rates => {
            :tiered_rate0 => {
              :from => ::TimeOfDay30mins.new(0, 0),
              :to => ::TimeOfDay30mins.new(0, 0),
              :per => :kwh,
              :tier0 => {
                :low_threshold => 0.0,
                :high_threshold => 1000.0,
                :rate => 0.45
              },
              :tier1 => {
                :low_threshold => 1000.0,
                :high_threshold => Float::INFINITY,
                :rate => 0.2
              }
            },
            :rate1 => {
              :from => ::TimeOfDay30mins.new(0, 30),
              :to => ::TimeOfDay30mins.new(23, 30),
              :per => :kwh,
              :rate => 0.1
            },
            :standing_charge => {
              :per => :day,
              :rate => standing_charge.value
            }
          },
          :type => :differential_tiered,
          :source => :dcc
        }]
      end

      it 'builds and returns the meter attributes' do
        attributes = factory.build
        expect(attributes).to_not be_nil
        expect(attributes[:accounting_tariff_generic]).to eql(expected_attributes)
      end
    end
  end
end
