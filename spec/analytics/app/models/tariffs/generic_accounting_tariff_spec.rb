# frozen_string_literal: true

require 'rails_helper'

describe GenericAccountingTariff, :aggregate_failures do
  let(:end_date)          { Date.today }
  let(:start_date)        { Date.today - 30 }
  let(:tariff_type)       { :flat }
  let(:rates)             { create_flat_rate }
  let(:kwh_data_x48)      { Array.new(48, 0.01) }
  let(:mpxn)              { 1_512_345_678_900 }

  let(:tariff_attribute) do
    create_accounting_tariff_generic(start_date: start_date, end_date: end_date, type: tariff_type, rates: rates)
  end

  let(:meter) { double(:meter) }

  let(:accounting_tariff)      { described_class.new(meter, tariff_attribute) }

  before do
    expect(meter).to receive(:mpxn).and_return(mpxn)
    expect(meter).to receive(:amr_data).and_return(nil)
    expect(meter).to receive(:fuel_type).and_return(:electricity)
  end

  describe '.initialize' do
    context 'with overlapping times ranges' do
      let(:rates) do
        {
          rate0: {
            from: TimeOfDay.new(10, 0),
            to: TimeOfDay.new(23, 30),
            per: :kwh,
            rate: 0.15
          },
          rate1: {
            from: TimeOfDay.new(0, 0),
            to: TimeOfDay.new(10, 30),
            per: :kwh,
            rate: 0.15
          }
        }
      end
      let(:tariff_attribute) { create_accounting_tariff_generic(type: :differential, rates: rates) }

      it 'raises exception' do
        expect { accounting_tariff }.to raise_error(GenericAccountingTariff::OverlappingTimeRanges)
      end
    end

    context 'with incomplete time ranges' do
      let(:rates) do
        {
          rate0: {
            from: TimeOfDay.new(10, 0),
            to: TimeOfDay.new(23, 30),
            per: :kwh,
            rate: 0.15
          }
        }
      end

      let(:tariff_attribute) { create_accounting_tariff_generic(type: :differential, rates: rates) }

      it 'raises exception' do
        expect { accounting_tariff }.to raise_error(GenericAccountingTariff::IncompleteTimeRanges)
      end
    end

    context 'with times not on half hours' do
      let(:rates) do
        {
          rate0: {
            from: TimeOfDay.new(7, 15),
            to: TimeOfDay.new(23, 30),
            per: :kwh,
            rate: 0.15
          },
          rate1: {
            from: TimeOfDay.new(0, 0),
            to: TimeOfDay.new(7, 0o0),
            per: :kwh,
            rate: 0.15
          }
        }
      end
      let(:tariff_attribute) { create_accounting_tariff_generic(type: :differential, rates: rates) }

      it 'raises exception' do
        expect { accounting_tariff }.to raise_error(GenericAccountingTariff::TimeRangesNotOn30MinuteBoundary)
      end
    end
  end

  describe '.differential?' do
    context 'with flat rate' do
      it 'identifies the type of tariff' do
        expect(accounting_tariff.differential?).to be false
        expect(accounting_tariff.flat_tariff?).to be true
      end
    end

    context 'with differential ' do
      let(:tariff_type)       { :differential }
      let(:rates)             { create_differential_rate }

      it 'identifies the type of tariff' do
        expect(accounting_tariff.differential?).to be true
        expect(accounting_tariff.flat_tariff?).to be false
      end
    end
  end

  describe '.default?' do
    let(:tariff_attribute) { create_accounting_tariff_generic(tariff_holder: :school) }

    context 'when default is not not set' do
      it 'treats school tariffs as not default' do
        expect(accounting_tariff.default?).to be false
      end
    end

    context 'when default explicitly set to true' do
      let(:tariff_attribute) { create_accounting_tariff_generic(default: true) }

      it 'returns true' do
        expect(accounting_tariff.default?).to be true
      end
    end

    context 'when tariff holder is a school group' do
      let(:tariff_attribute) { create_accounting_tariff_generic(tariff_holder: :school_group) }

      it 'returns true' do
        expect(accounting_tariff.default?).to be true
      end
    end
  end

  describe '.system_wide?' do
    let(:tariff_attribute) { create_accounting_tariff_generic(tariff_holder: :school) }

    context 'when not set' do
      it 'returns false' do
        expect(accounting_tariff.system_wide?).to be false
      end
    end

    context 'when explicitly set to true' do
      let(:tariff_attribute) { create_accounting_tariff_generic(system_wide: true) }

      it 'returns true' do
        expect(accounting_tariff.system_wide?).to be true
      end
    end

    context 'when tariff holder is site settings' do
      let(:tariff_attribute) { create_accounting_tariff_generic(tariff_holder: :site_settings) }

      it 'returns true' do
        expect(accounting_tariff.system_wide?).to be true
      end
    end
  end

  describe '.costs' do
    let(:accounting_cost) { accounting_tariff.costs(end_date, kwh_data_x48) }

    context 'with flat rate' do
      it 'calculates the expected cost' do
        expect(accounting_cost.differential_tariff?).to eq false
        expect(accounting_cost.standing_charges).to eq({})
        expect(accounting_cost.all_costs_x48['flat_rate']).to eq Array.new(48, 0.01 * 0.15)
      end

      context 'with a standing charge when available' do
        let(:rates) { create_flat_rate(rate: 0.15, standing_charge: 1.0) }

        it 'includes the charge' do
          expect(accounting_cost.standing_charges).to eq({ standing_charge: 1.0 })
        end
      end

      context 'with a kwh based standing charge' do
        let(:levy_rate) { 0.6 }
        let(:other_charges) do
          {
            feed_in_tariff_levy: {
              per: :kwh,
              rate: levy_rate
            }
          }
        end
        let(:rates) { create_flat_rate(other_charges: other_charges) }

        it 'includes the charge' do
          expect(accounting_cost.all_costs_x48['Feed in tariff levy']).to eq Array.new(48, 0.01 * levy_rate)
        end
      end

      context 'with climate change levy' do
        let(:tariff_attribute) do
          create_accounting_tariff_generic(start_date: start_date, end_date: end_date,
                                           type: tariff_type, climate_change_levy: true, rates: rates)
        end

        it 'includes the charge' do
          # value is from ClimateChangeLevy
          expect(accounting_cost.all_costs_x48[:climate_change_levy]).to eq Array.new(48, 0.01 * 0.00775)
        end
      end

      context 'with duos charges' do
        let(:accounting_cost) do
          # expects weekday
          travel_to(Time.utc(2024, 1, 26, 12)) { accounting_tariff.costs(end_date, kwh_data_x48) }
        end

        let(:other_charges) do
          {
            duos_red: 0.025,
            duos_amber: 0.015,
            duos_green: 0.01
          }
        end
        let(:rates) { create_flat_rate(other_charges: other_charges) }

        it 'includes the charges' do
          # check it calculates and we have non-zero values for each period
          expect(accounting_cost.all_costs_x48[:duos_red].sum).not_to be 0.0
          expect(accounting_cost.all_costs_x48[:duos_amber].sum).not_to be 0.0
          expect(accounting_cost.all_costs_x48[:duos_green].sum).not_to be 0.0
        end

        context 'when the DuoS region is unknown' do
          let(:mpxn)  { 2_712_345_678_900 }

          it 'includes the zero charges as a fallback' do
            # confirm that we've omitted these costs
            expect(accounting_cost.all_costs_x48[:duos_red]).to be_nil
            expect(accounting_cost.all_costs_x48[:duos_amber]).to be_nil
            expect(accounting_cost.all_costs_x48[:duos_green]).to be_nil
          end
        end
      end

      context 'with tnuous charge' do
        let(:other_charges) do
          {
            tnuos: true
          }
        end
        let(:rates) { create_flat_rate(other_charges: other_charges) }
        # let(:start_date) {Date.new(2022,1,1)}
        # let(:end_date)   {Date.new(2022,3,15)}

        # TODO: this currently doesn't work as the tnuos config is out of date
        xit 'includes the charge as a standing charge' do
          puts accounting_cost.inspect
        end
      end

      context 'with other standing charges' do
        let(:other_charges) do
          {
            data_collection_dcda_agent_charge: {
              per: :day,
              rate: 0.5
            }
          }
        end
        let(:rates) { create_flat_rate(other_charges: other_charges) }

        it 'adds them to standing charges' do
          expect(accounting_cost.standing_charges[:data_collection_dcda_agent_charge]).to eq(0.5)
        end
      end

      context 'with vat' do
        let(:vat) { '10%' }
        let(:tariff_attribute) do
          create_accounting_tariff_generic(start_date: start_date, end_date: end_date, type: tariff_type, rates: rates,
                                           vat: vat)
        end

        it 'calculates vat' do
          # ap accounting_cost.all_costs_x48
          expect(accounting_cost.all_costs_x48[:"vat@10%"]).to eq Array.new(48, 0.01 * 0.15 * 0.10)
        end

        context 'with a standing charge' do
          let(:rates) { create_flat_rate(rate: 0.15, standing_charge: 1.0) }

          it 'calculates vat' do
            usage_plus_vat = (0.01 * 0.15 * 0.10)
            standing_charge_plus_vat_x48 = (1.0 * 0.10) / 48
            expect(accounting_cost.all_costs_x48[:"vat@10%"]).to eq Array.new(48,
                                                                              usage_plus_vat + standing_charge_plus_vat_x48)
          end
        end
      end
    end

    context 'with differential rate' do
      let(:tariff_type) { :differential }
      let(:rates) { create_differential_rate(day_rate: 0.30, night_rate: 0.15, standing_charge: nil) }

      it 'calculates the expected cost' do
        expect(accounting_cost.differential_tariff?).to eq true
        expect(accounting_cost.standing_charges).to eq({})
        expect(accounting_cost.all_costs_x48['07:00 to 23:30']).to eq Array.new(14, 0.0) + Array.new(34, 0.01 * 0.15)
        expect(accounting_cost.all_costs_x48['00:00 to 06:30']).to eq Array.new(14, 0.01 * 0.30) + Array.new(34, 0.0)
      end
    end
  end

  describe '.economic_costs' do
    let(:economic_cost) { accounting_tariff.economic_costs(end_date, kwh_data_x48) }

    it 'calculates the expected cost' do
      expect(economic_cost.differential_tariff?).to eq false
      expect(economic_cost.standing_charges).to eq({})
      expect(economic_cost.all_costs_x48['flat_rate']).to eq Array.new(48, 0.01 * 0.15)
    end

    context 'with differential rate' do
      let(:tariff_type) { :differential }
      let(:rates) { create_differential_rate(day_rate: 0.30, night_rate: 0.15, standing_charge: nil) }

      it 'calculates the expected cost' do
        expect(economic_cost.differential_tariff?).to eq true
        expect(economic_cost.standing_charges).to eq({})
        expect(economic_cost.all_costs_x48['07:00 to 23:30']).to eq Array.new(14, 0.0) + Array.new(34, 0.01 * 0.15)
        expect(economic_cost.all_costs_x48['00:00 to 06:30']).to eq Array.new(14, 0.01 * 0.30) + Array.new(34, 0.0)
      end
    end
  end
end
