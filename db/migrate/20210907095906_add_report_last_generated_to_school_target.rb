class AddReportLastGeneratedToSchoolTarget < ActiveRecord::Migration[6.0]
  def change
    add_column :school_targets, :report_last_generated, :datetime, default: nil
  end
end
