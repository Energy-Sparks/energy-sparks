# frozen_string_literal: true

class AddVisibleSchoolsToImpactReportRun < ActiveRecord::Migration[8.1]
  def up
    add_column :impact_report_runs, :visible_schools, :integer, null: false, default: 0

    ImpactReport::Run.joins(:metrics)
                     .where(impact_report_metrics: { metric_type: :visible_schools })
                     .update_all('visible_schools = impact_report_metrics.value') # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    remove_column :impact_report_runs, :visible_schools
  end
end
