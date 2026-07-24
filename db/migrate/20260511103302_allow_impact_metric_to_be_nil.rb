# frozen_string_literal: true

class AllowImpactMetricToBeNil < ActiveRecord::Migration[8.1]
  def change
    change_column_null :impact_report_metrics, :value, true
  end
end
