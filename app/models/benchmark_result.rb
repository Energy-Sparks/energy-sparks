# == Schema Information
#
# Table name: benchmark_results
#
#  alert_type_id                             :bigint(8)        not null
#  asof                                      :date             not null
#  benchmark_result_school_generation_run_id :bigint(8)        not null
#  created_at                                :datetime         not null
#  id                                        :bigint(8)        not null, primary key
#  results                                   :json
#  results_cy                                :json
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

  #converts JSON which may contain, NAN, Float::Infinity,
  def self.convert_for_storage(json)
    return nil if json.nil?
    json.transform_values { |v| for_storage(v) }
  end

  def self.convert_for_processing(json)
    return nil if json.nil?
    json.transform_values { |v| for_processing(v) }
  end

  private_class_method def self.needs_conversion?(val)
    val.is_a?(Float) || val.is_a?(BigDecimal)
  end

  private_class_method def self.for_storage(val)
    return val if val.nil? || !needs_conversion?(val)
    if val.infinite? == 1
      ".inf"
    elsif val.infinite? == -1
      "-.Inf"
    elsif val.nan?
      ".NAN"
    else
      val
    end
  end

  private_class_method def self.for_processing(val)
    if val == ".inf"
      Float::INFINITY
    elsif val == "-.Inf"
      -Float::INFINITY
    elsif val == ".NAN"
      Float::NAN
    else
      val
    end
  end
end
