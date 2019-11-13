# == Schema Information
#
# Table name: benchmark_results
#
#  alert_generation_run_id :bigint(8)
#  alert_type_id           :bigint(8)
#  asof                    :date
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

class BenchmarkResult < ApplicationRecord
  store :data, coder: YAML
end
