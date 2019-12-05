require 'rails_helper'

module Alerts
  describe CollateBenchmarkData do

    let(:date_1)              { Date.parse('01/01/2019') }
    let(:date_2)              { Date.parse('01/01/2018') }
    let(:school_1)            { create(:school) }
    let(:school_2)            { create(:school) }
    let(:run_1)               { BenchmarkResultGenerationRun.create! }
    let(:run_2)               { BenchmarkResultGenerationRun.create! }
    let(:school_run_1)        { BenchmarkResultSchoolGenerationRun.create(school: school_1, benchmark_result_generation_run: run_1 ) }
    let(:school_run_2)        { BenchmarkResultSchoolGenerationRun.create(school: school_2, benchmark_result_generation_run: run_1 ) }
    let(:alert_type_1)        { create(:alert_type, benchmark: true, source: :analytics) }
    let(:alert_type_2)        { create(:alert_type, benchmark: true, source: :analytics) }

    let(:benchmark_result_1)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_1, benchmark_result_school_generation_run: school_run_1, data: {
      "number_example"=>1.0, "string_example"=>"A", "time_of_day"=> TimeOfDay.new(0,10)
    } )}
    let(:benchmark_result_2)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_2, benchmark_result_school_generation_run: school_run_1, data: {
      "number_example"=>2.0, "string_example"=>"B", "time_of_day"=> TimeOfDay.new(0,20)
    } )}
    let(:benchmark_result_3)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_1, benchmark_result_school_generation_run: school_run_1, data: {
       "number_example_2"=>3.0, "string_example_2"=>"C", "time_of_day_2"=> TimeOfDay.new(1,30)
    } )}
    let(:benchmark_result_4)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_2, benchmark_result_school_generation_run: school_run_1, data: {
       "number_example_2"=>4.0, "string_example_2"=>"D", "time_of_day_2"=> TimeOfDay.new(1,40)
    } )}

    let(:benchmark_result_5)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_1, benchmark_result_school_generation_run: school_run_2, data: {
      "number_example"=>5.0, "string_example"=>"E", "time_of_day"=> TimeOfDay.new(0,15)
    } )}
    let(:benchmark_result_6)  { BenchmarkResult.create!(alert_type: alert_type_1, asof: date_2, benchmark_result_school_generation_run: school_run_2, data: {
      "number_example"=>6.0, "string_example"=>"F", "time_of_day"=> TimeOfDay.new(0,30)
    } )}
    let(:benchmark_result_7)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_1, benchmark_result_school_generation_run: school_run_2, data: {
       "number_example_2"=>7.0, "string_example_2"=>"G", "time_of_day_2"=> TimeOfDay.new(1,35)
    } )}
    let(:benchmark_result_8)  { BenchmarkResult.create!(alert_type: alert_type_2, asof: date_2, benchmark_result_school_generation_run: school_run_2, data: {
       "number_example_2"=>8.0, "string_example_2"=>"H", "time_of_day_2"=> TimeOfDay.new(1,45)
    } )}

    let!(:example_output) {
      {
        date_1 => {
          school_1.id => benchmark_result_1.data.merge(benchmark_result_3.data) ,
          school_2.id => benchmark_result_5.data.merge(benchmark_result_7.data)
        },
        date_2 => {
          school_1.id => benchmark_result_2.data.merge(benchmark_result_4.data) ,
          school_2.id => benchmark_result_6.data.merge(benchmark_result_8.data)
        }
      }
    }

    let!(:example_output_school_1) {
      {
        date_1 => { school_1.id => benchmark_result_1.data.merge(benchmark_result_3.data) },
        date_2 => { school_1.id => benchmark_result_2.data.merge(benchmark_result_4.data) }
      }
    }

    it 'does the stuff' do
      expect(CollateBenchmarkData.new.perform).to eq example_output
    end

    it 'collates filtering by school' do
      expect(CollateBenchmarkData.new.perform([school_1])).to eq example_output_school_1
    end
  end
end
