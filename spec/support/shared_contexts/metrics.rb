RSpec.shared_context 'with some schools and metrics' do
  let!(:metric_type) { create(:metric_type) }

  let!(:school_1) { create(:school) }
  let!(:school_2) { create(:school) }

  let!(:run_1) { create(:benchmark_result_school_generation_run, school: school_1)}
  let!(:run_2) { create(:benchmark_result_school_generation_run, school: school_2)}

  let(:low_value) { 10 }
  let(:high_value) { 100 }

  # Setup test data so that we have
  # one run for each school, with one metric each, using the metric type that we'll be sorting on
  #
  # school_1 has low value, school_2 has high_value
  let!(:metric_1) { create(:metric, school: school_1, benchmark_result_school_generation_run: run_1, metric_type: metric_type, value: low_value) }
  let!(:metric_2) { create(:metric, school: school_2, benchmark_result_school_generation_run: run_2, metric_type: metric_type, value: high_value) }

  # ..plus one additional metric value to include in the results
  let!(:other_metric) { create(:metric, school: school_1, benchmark_result_school_generation_run: run_1, value: high_value) }
end
