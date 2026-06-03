# frozen_string_literal: true

require 'rails_helper'

describe ImpactReport::Run do
  context 'with valid attributes' do
    let(:run) { create(:impact_report_run) }

    it 'is valid' do
      expect(run).to be_valid
    end

    it 'belongs to school_group' do
      expect(run).to belong_to(:school_group)
    end

    it 'has many metrics dependent destroy' do
      expect(run).to have_many(:metrics).dependent(:destroy)
    end
  end

  describe 'associations' do
    let(:run) { create(:impact_report_run) }
    let!(:metric) { create(:impact_report_metric, run: run) }

    it 'has metrics' do
      expect(run.metrics).to include(metric)
    end
  end

  describe '.latest' do
    subject(:run) { described_class.latest }

    let!(:latest_run) { create(:impact_report_run, run_date: 1.day.ago) }

    before do
      create(:impact_report_run, run_date: 2.days.ago)
    end

    it 'returns the run with the most recent run_date' do
      expect(run).to eq(latest_run)
    end

    it 'includes metrics' do
      expect(run.association(:metrics)).to be_loaded
    end
  end

  describe '#enough_data?' do
    let(:run) { create(:impact_report_run) }

    context 'when visible_schools is >= 2 and enough_data? is true' do
      before do
        create(:impact_report_metric, run:, metric_category: 'overview',
                                      metric_type: 'visible_schools', value: 2, enough_data: true)
      end

      it { expect(run.enough_data?).to be(true) }
    end

    context 'when enough_data? is false' do
      before do
        create(:impact_report_metric, run:, metric_category: 'overview',
                                      metric_type: 'visible_schools', value: 2, enough_data: false)
      end

      it { expect(run.enough_data?).to be(false) }
    end

    context 'when visible schools < 2' do
      before do
        create(:impact_report_metric, run:, metric_category: 'overview',
                                      metric_type: 'visible_schools', value: 1, enough_data: true)
      end

      it { expect(run.enough_data?).to be(false) }
    end

    context 'when metric not present' do
      it { expect(run.enough_data?).to be(false) }
    end
  end

  describe '#overview' do
    let(:run) { create(:impact_report_run) }

    let!(:metric) do
      create(
        :impact_report_metric,
        run: run,
        metric_category: 'overview',
        metric_type: 'active_users',
        value: 10
      )
    end

    it 'delegates to #metric via dynamic method' do
      expect(run.overview(:active_users)).to eq(metric)
    end
  end

  describe '#engagement' do
    let(:run) { create(:impact_report_run) }

    let!(:metric) do
      create(
        :impact_report_metric,
        run: run,
        metric_category: 'engagement',
        metric_type: 'points',
        value: 10
      )
    end

    it 'delegates to #metric via dynamic method' do
      expect(run.engagement(:points)).to eq(metric)
    end
  end

  def create_metric(metric_type, fuel_type, value)
    create(:impact_report_metric, run:, metric_category:, fuel_type:, value:, metric_type:)
  end

  describe '#potential_savings' do
    let(:metric_category) { :potential_savings }

    context 'when ignoring irrelevant metrics' do
      subject(:run) { create(:impact_report_run) }

      let(:fuel_type) { :electricity }
      let!(:non_gbp_metric) do
        create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :baseload_kwh)
      end
      let!(:zero_metric) do
        create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :out_of_hours_gbp, value: 0)
      end
      let!(:no_data_metric) do
        create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :peak_gbp, enough_data: false)
      end
      let!(:ok_metric) { create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :baseload_gbp) }

      it 'includes nonzero gbp metrics with enough_data' do
        expect(run.potential_savings).to include(ok_metric)
      end

      it 'filters out non-gbp metrics' do
        expect(run.potential_savings).not_to include(non_gbp_metric)
      end

      it 'filters out zero metrics' do
        expect(run.potential_savings).not_to include(zero_metric)
      end

      it 'filters out metrics without enough_data' do
        expect(run.potential_savings).not_to include(no_data_metric)
      end
    end

    context 'when sorting metrics' do
      subject(:potential_savings) { run.potential_savings.map(&:metric_type) }

      let(:run) { create(:impact_report_run) }

      context 'when there are only electricity metrics' do
        before do
          create_metric(:baseload_gbp, :electricity, 3)
          create_metric(:out_of_hours_gbp, :electricity, 4)
        end

        it 'returns metrics with the highest value first' do
          expect(potential_savings).to eq(%w[out_of_hours_gbp baseload_gbp])
        end
      end

      context 'when there are 2 electicity metrics and a gas metric' do
        before do
          create_metric(:baseload_gbp, :electricity, 3)
          create_metric(:out_of_hours_gbp, :electricity, 4)
          create_metric(:insulate_pipes_gbp, :gas, 3)
        end

        it 'returns highest electricity, then gas, then next elec' do
          expect(potential_savings).to eq(%w[out_of_hours_gbp insulate_pipes_gbp baseload_gbp])
        end
      end

      context 'when there are 2 electricity metrics and a solar metric' do
        before do
          create_metric(:baseload_gbp, :electricity, 3)
          create_metric(:out_of_hours_gbp, :electricity, 4)
          create_metric(:solar_panels_gbp, :solar_pv, 3)
        end

        it 'returns highest electricity, then solar, then next elec' do
          expect(potential_savings).to eq(%w[out_of_hours_gbp solar_panels_gbp baseload_gbp])
        end
      end
    end
  end

  describe '#energy_efficiency' do
    subject(:energy_efficiency) { run.energy_efficiency }

    before { create(:commercial_product, default_product: true, large_school_price: 200) }

    let(:metric_category) { :energy_efficiency }
    let(:run) { create(:impact_report_run) }

    context 'with all metrics' do
      let!(:annual_saving_gbp_gas) { create_metric(:annual_saving_gbp, :gas, 300) }
      let!(:annual_saving_gbp_electricity) { create_metric(:annual_saving_gbp, :electricity, 400) }
      let!(:annual_saving_co2_gas) { create_metric(:annual_saving_co2, :gas, 500) }
      let!(:annual_saving_co2_electricity) { create_metric(:annual_saving_co2, :electricity, 600) }
      let!(:targets_gas) { create_metric(:targets, :gas, 12) }
      let!(:targets_electricity) { create_metric(:targets, :electricity, 1) }

      it 'returns metrics in configured order, gas first, then electricity' do
        expect(energy_efficiency).to eq(
          [annual_saving_gbp_gas, annual_saving_gbp_electricity,
           annual_saving_co2_gas, annual_saving_co2_electricity,
           targets_gas, targets_electricity]
        )
      end
    end

    context 'with just gas metrics' do
      let!(:annual_saving_gbp_gas) { create_metric(:annual_saving_gbp, :gas, 300) }
      let!(:annual_saving_co2_gas) { create_metric(:annual_saving_co2, :gas, 500) }

      it 'returns metrics in configured order, gas first, then electricity' do
        expect(energy_efficiency).to eq(
          [annual_saving_gbp_gas, annual_saving_co2_gas]
        )
      end
    end

    context 'when filtering metrics' do
      before do
        create(:impact_report_metric, run:, metric_category:,
                                      fuel_type: :electricity, metric_type: :annual_saving_gbp, value: 45)
        create(:impact_report_metric, run:, metric_category:,
                                      fuel_type: :gas, metric_type: :annual_saving_co2, enough_data: false)
      end

      let!(:ok_metric) do
        create(:impact_report_metric, run:, metric_category:,
                                      fuel_type: :gas, metric_type: :annual_saving_gbp, value: 300, enough_data: true)
      end

      it { expect(energy_efficiency).to eq([ok_metric]) }
    end
  end

  describe 'metrics indexing' do
    subject(:index) { run.send(:metrics_index) }

    let(:run) { create(:impact_report_run) }

    let!(:active_users) do
      create(:impact_report_metric,
             run: run,
             metric_category: 'overview',
             metric_type: 'active_users')
    end

    let!(:points) do
      create(:impact_report_metric,
             run: run,
             metric_category: 'engagement',
             metric_type: 'points')
    end

    let!(:baseload_gbp) do
      create(:impact_report_metric,
             run: run,
             fuel_type: 'electricity',
             metric_category: 'potential_savings',
             metric_type: 'baseload_gbp')
    end

    let!(:annual_saving_gbp) do
      create(:impact_report_metric,
             run: run,
             fuel_type: 'electricity',
             metric_category: 'energy_efficiency',
             metric_type: 'annual_saving_gbp')
    end

    it 'memoizes the index' do
      expect(index).to equal(run.send(:metrics_index))
    end

    it 'stores overview metrics in a hash' do
      expect(index['overview']['active_users'][nil]).to equal(active_users)
    end

    it 'stores engagemement metrics in a hash' do
      expect(index['engagement']['points'][nil]).to equal(points)
    end

    it 'stores energy efficiency metrics in a hash' do
      expect(index['energy_efficiency']['annual_saving_gbp']['electricity']).to equal(annual_saving_gbp)
    end

    it 'stores potential savings metrics in an array' do
      expect(index['potential_savings']['electricity']).to eq([baseload_gbp])
    end
  end
end
