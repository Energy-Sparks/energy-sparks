# == Schema Information
#
# Table name: benchmark_results
#
#  alert_generation_run_id :bigint(8)
#  alert_type_id           :bigint(8)
#  asof                    :date             not null
#  created_at              :datetime         not null
#  data                    :text
#  id                      :bigint(8)        not null, primary key
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_benchmark_results_on_alert_generation_run_id  (alert_generation_run_id)
#  index_benchmark_results_on_alert_type_id            (alert_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_generation_run_id => alert_generation_runs.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#

class BenchmarkResult < ApplicationRecord
  belongs_to :alert_generation_run
  belongs_to :alert_type

  store :data, coder: YAML
end
