# == Schema Information
#
# Table name: benchmark_result_errors
#
#  alert_type_id                             :bigint(8)        not null
#  asof_date                                 :date
#  benchmark_result_school_generation_run_id :bigint(8)        not null
#  created_at                                :datetime         not null
#  id                                        :bigint(8)        not null, primary key
#  information                               :text
#  updated_at                                :datetime         not null
#
# Indexes
#
#  ben_rgr_errors_index                            (benchmark_result_school_generation_run_id)
#  index_benchmark_result_errors_on_alert_type_id  (alert_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#  fk_rails_...  (benchmark_result_school_generation_run_id => benchmark_result_school_generation_runs.id) ON DELETE => cascade
#

class BenchmarkResultError < ApplicationRecord
  belongs_to :alert_type
  belongs_to :benchmark_result_school_generation_run, counter_cache: :benchmark_result_error_count
end
