class AddDisableNormalisationToeToComparisonReports < ActiveRecord::Migration[7.2]
  def change
    add_column :comparison_reports, :disable_normalisation, :boolean, default: false, null: false
  end
end
