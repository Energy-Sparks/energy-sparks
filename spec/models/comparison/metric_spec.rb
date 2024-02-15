require 'rails_helper'

RSpec.describe Comparison::Metric, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      subject(:metric) { create :metric }

      it { expect(metric).to be_valid }
      it { expect(metric).to validate_presence_of(:school) }
      it { expect(metric).to validate_presence_of(:alert_type) }
      it { expect(metric).to validate_presence_of(:metric_type) }
      it { expect(metric).not_to validate_presence_of(:asof_date) }
    end

    it_behaves_like 'an enum reporting period', model: :metric
  end

  describe 'value serialisation' do
    let!(:metric) { create(:metric, value: value) }

    # force database round-trip
    before { metric.reload }

    shared_examples 'a correctly round-tripped metric' do
      it { expect(metric.value).to eq value}
      it { expect(metric.value.class).to eq value.class}
      it { expect(Comparison::Metric.find_by(value: value)).to eq(metric) }
    end

    context 'with basic types' do
      context 'with floats' do
        let(:value) { 0.5 }

        it_behaves_like 'a correctly round-tripped metric'
      end

      context 'with integer' do
        let(:value) { 2 }

        it_behaves_like 'a correctly round-tripped metric'
      end

      context 'with String' do
        let(:value) { 'foo' }

        it_behaves_like 'a correctly round-tripped metric'
      end

      context 'with boolean' do
        let(:value) { true }

        it_behaves_like 'a correctly round-tripped metric'
      end

      context 'with Date' do
        let(:value) { Time.zone.today }

        it_behaves_like 'a correctly round-tripped metric'
      end
    end

    context 'with analytics types' do
      context 'with TimeOfDay' do
        let(:value) { TimeOfDay.new(10, 30) }

        it_behaves_like 'a correctly round-tripped metric'
      end
    end

    context 'with Nan/Infinite values' do
      context 'with Nan' do
        let(:value) { Float::NAN }

        it { expect(metric.value).to be_nan}
        it { expect(metric.value.class).to eq value.class}
        it { expect(Comparison::Metric.find_by(value: value)).to eq(metric) }
      end

      context 'with Infinity' do
        let(:value) { Float::INFINITY }

        it_behaves_like 'a correctly round-tripped metric'
      end

      context 'with -Infinity' do
        let(:value) { -Float::INFINITY }

        it_behaves_like 'a correctly round-tripped metric'
      end

      context 'with BigDecimal Infinity' do
        let(:value) { BigDecimal('Infinity') }

        it { expect(metric.value).to eq Float::INFINITY}
        it { expect(metric.value.class).to eq Float}
        it { expect(Comparison::Metric.find_by(value: value)).to eq(metric) }
      end

      context 'with BigDecimal -Infinity' do
        let(:value) { BigDecimal('-Infinity') }

        it { expect(metric.value).to eq(-Float::INFINITY)}
        it { expect(metric.value.class).to eq Float}
        it { expect(Comparison::Metric.find_by(value: value)).to eq(metric) }
      end

      context 'with BigDecimal +Infinity' do
        let(:value) { BigDecimal('+Infinity') }

        it { expect(metric.value).to eq Float::INFINITY}
        it { expect(metric.value.class).to eq Float}
        it { expect(Comparison::Metric.find_by(value: value)).to eq(metric) }
      end
    end
  end

  describe '.for_latest_benchmark_runs' do
    context 'with multiple runs for a school' do
      let!(:school) { create(:school) }
      let!(:metric_type) { create(:metric_type) }
      let!(:runs) { create_list(:benchmark_result_school_generation_run, 2, school: school) }
      let!(:metric_1) { create(:metric, school: school, benchmark_result_school_generation_run: runs[0], metric_type: metric_type) }
      let!(:metric_2) { create(:metric, school: school, benchmark_result_school_generation_run: runs[1], metric_type: metric_type) }

      it 'returns the latest metric' do
        expect(Comparison::Metric.for_latest_benchmark_runs.count).to eq(1)
        expect(Comparison::Metric.for_latest_benchmark_runs.first).to eq(metric_2)
      end
    end

    context 'with multiple schools and runs' do
      let!(:metric_type) { create :metric_type }

      before do
        # Setup test data so we have:
        # 1 school with no runs or metrics
        create(:school)
        # 1 school with one run and 1 metric
        create(:metric, metric_type: metric_type)
        # 1 school with two runs, one with 2 metrics and most recent with 1 metric
        school = create(:school)
        runs = create_list(:benchmark_result_school_generation_run, 2, school: school)
        create(:metric, school: school, benchmark_result_school_generation_run: runs[0], metric_type: metric_type)
        create(:metric, school: school, benchmark_result_school_generation_run: runs[0])
        create(:metric, school: school, benchmark_result_school_generation_run: runs[1], metric_type: metric_type)
      end

      it 'returns latest metrics for each school' do
        # one for each school, and only metrics with latest run for each
        expect(Comparison::Metric.for_latest_benchmark_runs.count).to eq(2)
        expect(Comparison::Metric.for_latest_benchmark_runs.map(&:metric_type).uniq).to eq([metric_type])
      end
    end
  end

  describe '.order_by_school_metric_value' do
    let!(:metric_type) { create(:metric_type) }

    let!(:school_1) { create(:school) }
    let!(:school_2) { create(:school) }

    let!(:run_1) { create(:benchmark_result_school_generation_run, school: school_1)}
    let!(:run_2) { create(:benchmark_result_school_generation_run, school: school_2)}

    # Setup test data so that we have
    # one run for each school, with one metric and metric type that we'll be sorting one
    #
    # school_1 has low value, school_2 has high_value
    let!(:metric_1) { create(:metric, school: school_1, benchmark_result_school_generation_run: run_1, metric_type: metric_type, value: low_value) }
    let!(:metric_2) { create(:metric, school: school_2, benchmark_result_school_generation_run: run_2, metric_type: metric_type, value: high_value) }

    # ..plus one additional metric value that should be unused in sort
    let!(:other_metric) { create(:metric, school: school_1, benchmark_result_school_generation_run: run_1, value: high_value) }

    shared_examples 'it sorts and returns results correctly' do
      subject(:results) { Comparison::Metric.order_by_school_metric_value(metric_type, order)}

      context 'with :desc order' do
        let(:order) { :desc }

        it 'returns school with highest value first' do
          expect(results[0].school).to eq(school_2)
          expect(results[1].school).to eq(school_1)
          expect(results[2].school).to eq(school_1)
        end

        it 'returns all the metrics' do
          expect(results.count).to eq(3)
        end
      end

      context 'with :asc order' do
        let(:order) { :asc }

        it 'returns school with highest value first' do
          expect(results[0].school).to eq(school_1)
          expect(results[1].school).to eq(school_1)
          expect(results[2].school).to eq(school_2)
        end

        it 'returns all the metrics' do
          expect(results.count).to eq(3)
        end
      end
    end

    context 'with integer values' do
      let(:low_value) { 1 }
      let(:high_value) { 10 }

      it_behaves_like 'it sorts and returns results correctly'
    end

    context 'with Date values' do
      let(:low_value) { Date.new(2024, 1, 1) }
      let(:high_value) { Date.new(2024, 2, 1) }

      it_behaves_like 'it sorts and returns results correctly'
    end

    context 'with float values' do
      let(:low_value) { 0.1 }
      let(:high_value) { 1.1 }

      it_behaves_like 'it sorts and returns results correctly'

      context 'with NAN value' do
        let(:high_value) { Float::NAN }

        it_behaves_like 'it sorts and returns results correctly'
      end

      context 'with Infinite value' do
        let(:high_value) { Float::INFINITY }

        it_behaves_like 'it sorts and returns results correctly'
      end
    end
  end
end
