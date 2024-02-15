# == Schema Information
#
# Table name: benchmark_result_school_generation_runs
#
#  benchmark_result_count             :integer          default(0)
#  benchmark_result_error_count       :integer          default(0)
#  benchmark_result_generation_run_id :bigint(8)
#  created_at                         :datetime         not null
#  id                                 :bigint(8)        not null, primary key
#  school_id                          :bigint(8)        not null
#  updated_at                         :datetime         not null
#
# Indexes
#
#  benchmark_result_school_generation_run_idx                  (benchmark_result_generation_run_id)
#  index_benchmark_result_school_generation_runs_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (benchmark_result_generation_run_id => benchmark_result_generation_runs.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class BenchmarkResultSchoolGenerationRun < ApplicationRecord
  belongs_to :school
  belongs_to :benchmark_result_generation_run
  has_many :benchmark_results
  has_many :benchmark_result_errors
  has_many :metrics, class_name: 'Comparison::Metric'

  # Uses the Postgres DISTINCT ON operator to only return the latest run for each school
  #
  # We specify the school id as the distinct column, then order by created at DESC to select
  # the most recent benchmark run for a school.
  #
  # The INNER JOIN is required to allows us to `.merge` this scope with others (e.g. in MetricType)
  scope :most_recent, -> {
    joins(<<~SQL.squish)
      INNER JOIN
        (SELECT DISTINCT ON (school_id) * FROM benchmark_result_school_generation_runs
         ORDER BY school_id, created_at DESC
        ) latest_runs
        ON latest_runs.id = benchmark_result_school_generation_runs.id
    SQL
  }
end
