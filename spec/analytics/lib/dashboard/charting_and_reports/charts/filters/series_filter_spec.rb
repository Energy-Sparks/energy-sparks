# frozen_string_literal: true

require 'rails_helper'

describe Charts::Filters::SeriesFilter do
  subject(:filter) do
    described_class.new(meter_collection, chart_config, aggregator_results)
  end

  let(:meter_collection) { instance_double(MeterCollection) }
  let(:aggregator_results) { AggregatorResults.new }
  let(:chart_config) do
    {
      name: 'Testing',
      meter_definition: :allelectricity,
      series_breakdown: :submeter,
      x_axis: :month,
      timescale: :up_to_a_year
    }
  end

  describe '#filter' do
    let(:aggregator_results) { AggregatorResults.new(bucketed_data: bucketed_data) }

    let(:bucketed_data) do
      {
        SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME => [],
        SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME => [],
        SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME => [],
        SolarPVPanels::SOLAR_PV_PRODUCTION_METER_NAME => []
      }
    end

    context 'with no filter' do
      it 'does nothing' do
        filter.filter
        expect(aggregator_results.bucketed_data).to eq(bucketed_data)
      end
    end

    context 'with a submeter filter' do
      let(:series_manager) { instance_double(Series::ManagerBase) }
      let(:aggregator_results) { AggregatorResults.new(series_manager: series_manager, bucketed_data: bucketed_data) }

      before do
        meter = instance_double(Dashboard::Meter)
        allow(series_manager).to receive(:meter).and_return(meter)
        allow(meter).to receive(:sub_meters).and_return(sub_meters)
      end

      context 'when filtering solar submeters' do
        let(:sub_meters) do
          {
            export: build(:meter, name: SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME),
            generation: build(:meter, name: SolarPVPanels::SOLAR_PV_PRODUCTION_METER_NAME),
            self_consume: build(:meter, name: SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME),
            mains_consume: build(:meter, name: SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME),
            mains_plus_self_consume: build(:meter, name: SolarPVPanels::MAINS_ELECTRICITY_CONSUMPTION_INCLUDING_ONSITE_PV)
          }
        end

        let(:chart_config) do
          {
            name: 'Testing',
            meter_definition: :allelectricity,
            series_breakdown: :submeter,
            x_axis: :month,
            timescale: :up_to_a_year,
            filter: {
              submeter: %i[
                mains_consume
                export
                self_consume
              ]
            }
          }
        end

        before do
          filter.filter
        end

        it 'filters to the submeters' do
          # should drop just the Solar PV production (:generation) meter
          expect(aggregator_results.bucketed_data.keys).to match_array(
            [
              SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME,
              SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME,
              SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME
            ]
          )
        end

        context 'with a solar irradiance y2 axis' do
          let(:chart_config) do
            {
              name: 'Testing',
              meter_definition: :allelectricity,
              series_breakdown: :submeter,
              x_axis: :month,
              timescale: :up_to_a_year,
              filter: {
                submeter: %i[
                  mains_consume
                  export
                  self_consume
                ]
              },
              y2_axis: :irradiance
            }
          end

          let(:bucketed_data) do
            {
              SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME => [],
              SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME => [],
              SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME => [],
              SolarPVPanels::SOLAR_PV_PRODUCTION_METER_NAME => [],
              Series::Irradiance::IRRADIANCE => []
            }
          end

          it 'keeps the y2 axis as well' do
            # should drop just the Solar PV production (:generation) meters
            expect(aggregator_results.bucketed_data.keys).to match_array(
              [
                SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME,
                SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME,
                SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME,
                Series::Irradiance::IRRADIANCE
              ]
            )
          end
        end
      end
    end

    context 'with a heating filter' do
      let(:chart_config) do
        {
          name: 'Testing',
          meter_definition: :allheat,
          x_axis: :day,
          timescale: :up_to_a_year,
          series_breakdown: [:heating],
          filter: { heating: true }
        }
      end

      let(:bucketed_data) do
        {
          Series::HeatingNonHeating::HEATINGDAY => [],
          Series::HeatingNonHeating::NONHEATINGDAY => [],
          Series::HeatingNonHeating::HEATINGDAYWARMWEATHER => []
        }
      end

      it 'filters to just heating days' do
        filter.filter
        expect(aggregator_results.bucketed_data.keys).to match_array(
          [Series::HeatingNonHeating::HEATINGDAY]
        )
      end
    end

    context 'with a day type filter' do
      let(:chart_config) do
        {
          name: 'Testing',
          meter_definition: :allelectricity,
          x_axis: :intraday,
          timescale: :up_to_a_year,
          filter: {
            daytype: [Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED]
          }
        }
      end

      let(:bucketed_data) do
        {
          Series::DayType::SCHOOLDAYOPEN => [],
          Series::DayType::SCHOOLDAYCLOSED => [],
          Series::DayType::WEEKEND => [],
          Series::DayType::HOLIDAY => []
        }
      end

      it 'filters to just those day types' do
        filter.filter
        expect(aggregator_results.bucketed_data.keys).to match_array(
          [Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED]
        )
      end
    end
  end
end
