require 'rails_helper'

describe Alerts::DeleteBenchmarkRunService, type: :service do

  let(:created_at)        { Time.zone.now }

  let!(:school)            { create(:school) }
  let!(:run)               { BenchmarkResultGenerationRun.create(created_at: created_at) }
  let!(:school_run)        { BenchmarkResultSchoolGenerationRun.create(school: school,
    benchmark_result_generation_run: run ) }
  let!(:alert_type)        { create(:alert_type, benchmark: true, source: :analytics) }
  let!(:benchmark_result)  { BenchmarkResult.create!(alert_type: alert_type,
    asof: Date.today, benchmark_result_school_generation_run: school_run) }

  let!(:benchmark_error)    { BenchmarkResultError.create!(
                              alert_type: alert_type,
                              benchmark_result_school_generation_run: school_run,
                              information: 'Something went terribly wrong')
                            }

  let(:service)   { Alerts::DeleteBenchmarkRunService.new }

  it 'defaults to beginning of month, 1 month ago' do
    expect(service.older_than).to eql(1.months.ago.beginning_of_month)
  end

  it 'doesnt delete new runs' do
    expect(BenchmarkResultGenerationRun.count).to eq 1
    expect {service.delete!}.not_to change(BenchmarkResultGenerationRun, :count)
  end

  context 'when there are older runs to delete' do
    let(:created_at)        { Time.zone.now - 3.months }

    let!(:new_run)          { BenchmarkResultGenerationRun.create! }
    let!(:new_school_run)   { BenchmarkResultSchoolGenerationRun.create(school: school,
      benchmark_result_generation_run: new_run ) }
    let!(:new_benchmark_result)  { BenchmarkResult.create!(alert_type: alert_type,
        asof: Date.today, benchmark_result_school_generation_run: new_school_run) }

    it 'deletes only the older runs' do
      expect(BenchmarkResultGenerationRun.count).to eq 2
      expect {service.delete!}.to change(BenchmarkResultGenerationRun, :count).by(-1)
    end

    it 'deletes all of the dependent objects' do
      expect(BenchmarkResultSchoolGenerationRun.count).to eql 2
      expect(BenchmarkResult.count).to eql 2
      expect(BenchmarkResultError.count).to eql 1
      service.delete!
      expect(BenchmarkResultSchoolGenerationRun.count).to eql 1
      expect(BenchmarkResult.count).to eql 1
      expect(BenchmarkResultError.count).to eql 0
    end

  end

end
