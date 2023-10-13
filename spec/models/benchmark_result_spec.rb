require 'rails_helper'

describe BenchmarkResult do
  let(:alert_type)     { create(:alert_type, fuel_type: nil, frequency: :weekly, source: :analytics, benchmark: true) }
  let!(:benchmark_run) { create(:benchmark_result_school_generation_run) }

  describe '#convert_for_processing' do
    it 'returns simple json unchanged' do
      data = { foo: 123, bar: 1.2, other: "String", check: true, var: Date.new(2022, 4, 1) }
      expect(BenchmarkResult.convert_for_processing(data)).to eq({
          foo: 123,
          bar: 1.2,
          other: "String",
          check: true,
          var: Date.new(2022, 4, 1)
        })
    end

    it 'replaces .inf with Infinity' do
      data = { foo: 123, bar: 1.2, var: ".inf" }
      expect(BenchmarkResult.convert_for_processing(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: Float::INFINITY
        })
    end

    it 'replaces -.Inf with -Infinity' do
      data = { foo: 123, bar: 1.2, var: "-.Inf" }
      expect(BenchmarkResult.convert_for_processing(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: -Float::INFINITY
        })
    end

    it 'replaces .Nan with NaN' do
      data = { foo: 123, bar: 1.2, var: ".NAN" }
      expect(BenchmarkResult.convert_for_processing(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: Float::NAN
        })
    end
  end

  describe '#convert_for_storage' do
    it 'leaves simple json unchanged' do
      data = { foo: 123, bar: 1.2, var: Date.new(2022, 4, 1) }
      expect(BenchmarkResult.convert_for_storage(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: Date.new(2022, 4, 1)
        })
    end

    it 'replaces Infinity with .inf' do
      data = { foo: 123, bar: 1.2, var: Float::INFINITY }
      expect(BenchmarkResult.convert_for_storage(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: ".inf"
        })
      data = { foo: 123, bar: 1.2, var: BigDecimal('Infinity') }
      expect(BenchmarkResult.convert_for_storage(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: ".inf"
        })
    end

    it 'replaces -Infinity with -.Inf' do
      data = { foo: 123, bar: 1.2, var: -Float::INFINITY }
      expect(BenchmarkResult.convert_for_storage(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: "-.Inf"
        })
      data = { foo: 123, bar: 1.2, var: BigDecimal('-Infinity') }
      expect(BenchmarkResult.convert_for_storage(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: "-.Inf"
        })
    end

    it 'replaces with NaN with .NaN' do
      data = { foo: 123, bar: 1.2, var: Float::NAN }
      expect(BenchmarkResult.convert_for_storage(data)).to eq({
          foo: 123,
          bar: 1.2,
          var: ".NAN"
        })
    end
  end
end
