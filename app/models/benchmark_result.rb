# == Schema Information
#
# Table name: benchmark_results
#
#  alert_type_id                             :bigint(8)        not null
#  asof                                      :date             not null
#  benchmark_result_school_generation_run_id :bigint(8)        not null
#  created_at                                :datetime         not null
#  data                                      :text
#  id                                        :bigint(8)        not null, primary key
#  updated_at                                :datetime         not null
#
# Indexes
#
#  ben_rgr_index                             (benchmark_result_school_generation_run_id)
#  index_benchmark_results_on_alert_type_id  (alert_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#  fk_rails_...  (benchmark_result_school_generation_run_id => benchmark_result_school_generation_runs.id) ON DELETE => cascade
#

class BenchmarkResult < ApplicationRecord
  belongs_to :benchmark_result_school_generation_run, counter_cache: :benchmark_result_count
  belongs_to :alert_type

  store :data, coder: YAML
end
