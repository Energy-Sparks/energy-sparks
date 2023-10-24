require 'rails_helper'

module Alerts
  describe CollateBenchmarkData do
    let(:school_1)            { create(:school) }
    let(:school_2)            { create(:school) }
    let(:run)                 { BenchmarkResultGenerationRun.create! }
    let(:date_1)              { run.run_date }
    let(:date_2)              { run.run_date }

    let(:school_run_1)        { BenchmarkResultSchoolGenerationRun.create(school: school_1, benchmark_result_generation_run: run) }
    let(:school_run_2_old)    { BenchmarkResultSchoolGenerationRun.create(school: school_2, benchmark_result_generation_run: run) }
    let(:school_run_2)        { BenchmarkResultSchoolGenerationRun.create(school: school_2, benchmark_result_generation_run: run) }
    let(:alert_type_1)        { create(:alert_type, benchmark: true, source: :analytics) }
    let(:alert_type_2)        { create(:alert_type, benchmark: true, source: :analytics) }

    let(:variables_1)         { { "number_example" => 1.0, "string_example" => "A", "time_of_day" => TimeOfDay.new(0, 10) } }
    let(:variables_2)         { { "number_example" => 2.0, "string_example" => "B", "time_of_day" => TimeOfDay.new(0, 20) } }
    let(:variables_3)         { { "number_example_2" => 3.0, "string_example_2" => "C", "time_of_day_2" => TimeOfDay.new(1, 30) } }
    let(:variables_4)         { { "number_example_2" => 4.0, "string_example_2" => "D", "time_of_day_2" => TimeOfDay.new(1, 40) } }
    let(:variables_5)         { { "number_example" => 5.0, "string_example" => "E", "time_of_day" => TimeOfDay.new(0, 15) } }
    let(:variables_6)         { { "number_example" => 6.0, "string_example" => "F", "time_of_day" => TimeOfDay.new(0, 30) } }
    let(:variables_7)         { { "number_example_2" => 7.0, "string_example_2" => "G", "time_of_day_2" => TimeOfDay.new(1, 35) } }
    let(:variables_8)         { { "number_example_2" => 8.0, "string_example_2" => "H", "time_of_day_2" => TimeOfDay.new(1, 45) } }
    let(:variables_9)         { { "number_example_2" => 9.0, "string_example_2" => "H", "time_of_day_2" => TimeOfDay.new(1, 45) } }

    let(:benchmark_result_1)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_1, benchmark_result_school_generation_run: school_run_1, results: variables_1)}

    let(:benchmark_result_2)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_2, benchmark_result_school_generation_run: school_run_1, results: variables_2)}
    let(:benchmark_result_3)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_1, benchmark_result_school_generation_run: school_run_1, results: variables_3)}
    let(:benchmark_result_4)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_2, benchmark_result_school_generation_run: school_run_1, results: variables_4)}

    let(:benchmark_result_5)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_1, benchmark_result_school_generation_run: school_run_2, results: variables_5)}
    let(:benchmark_result_6)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_2, benchmark_result_school_generation_run: school_run_2, results: variables_6)}
    let(:benchmark_result_7)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_1, benchmark_result_school_generation_run: school_run_2, results: variables_7)}
    let(:benchmark_result_8)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_2, benchmark_result_school_generation_run: school_run_2, results: variables_8)}

    # this older run for school_2 should be overridden in the results by the later one
    let!(:benchmark_result_9) { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_2, benchmark_result_school_generation_run: school_run_2_old, results: variables_9)}

    let!(:example_output) do
      {
        date_1 => {
          school_1.id => benchmark_result_1.results.merge(benchmark_result_3.results),
          school_2.id => benchmark_result_5.results.merge(benchmark_result_7.results)
        },
        date_2 => {
          school_1.id => benchmark_result_2.results.merge(benchmark_result_4.results),
          school_2.id => benchmark_result_6.results.merge(benchmark_result_8.results)
        }
      }
    end

    let!(:example_output_school_1) do
      {
        date_1 => { school_1.id => benchmark_result_1.results.merge(benchmark_result_3.results) },
        date_2 => { school_1.id => benchmark_result_2.results.merge(benchmark_result_4.results) }
      }
    end

    let!(:example_output_school_1_as_json) do
      {
        date_1 => { school_1.id => benchmark_result_1.results.merge(benchmark_result_3.results) },
        date_2 => { school_1.id => benchmark_result_2.results.merge(benchmark_result_4.results) }
      }
    end

    it 'does the stuff' do
      expect(CollateBenchmarkData.new(run).perform).to eq example_output
    end

    it 'collates filtering by school' do
      expect(CollateBenchmarkData.new(run).perform([school_1])).to eq example_output_school_1
    end
  end
end
