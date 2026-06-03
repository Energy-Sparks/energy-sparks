# frozen_string_literal: true

require 'rails_helper'

describe AggregatorConfig do
  subject(:config) do
    described_class.new(chart_config)
  end

  let(:chart_config) { {} }

  describe '#month_comparison?' do
    context 'with no timescale in config' do
      it { expect(config.month_comparison?).to be false }
    end

    context 'with config' do
      let(:chart_config) do
        {
          timescale: timescale,
          x_axis: x_axis
        }
      end
      let(:timescale) { nil }

      context 'with a non month x-axis' do
        let(:x_axis) { :day }

        it { expect(config.month_comparison?).to be false }

        context 'when timescale is a comparison' do
          let(:timescale) do
            [{ up_to_a_year: 0 }, { up_to_a_year: -1 }]
          end

          it { expect(config.month_comparison?).to be false }
        end
      end

      %i[month month_excluding_year].each do |x_axis|
        context "with a #{x_axis} x-axis" do
          let(:x_axis) { x_axis }

          context 'when timescale is a single period' do
            let(:timescale) { :year }

            it { expect(config.month_comparison?).to be false }
          end

          context 'when timescale isnt a comparison' do
            let(:timescale) { [{ year: 0 }] }

            it { expect(config.month_comparison?).to be false }
          end

          context 'with :year timescale comparison' do
            let(:timescale) do
              [{ year: 0 }, { year: -1 }]
            end

            it { expect(config.month_comparison?).to be false }
          end

          context 'with :up_to_a_year timescale comparison' do
            let(:timescale) do
              [{ up_to_a_year: 0 }, { up_to_a_year: -1 }]
            end

            it { expect(config.month_comparison?).to be true }
          end

          context 'with :twelve_months timescale comparison' do
            let(:timescale) do
              [{ twelve_months: 0 }, { twelve_months: -1 }]
            end

            it { expect(config.month_comparison?).to be true }
          end
        end
      end
    end
  end
end
