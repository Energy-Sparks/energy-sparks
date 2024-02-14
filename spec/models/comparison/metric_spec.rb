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
end
