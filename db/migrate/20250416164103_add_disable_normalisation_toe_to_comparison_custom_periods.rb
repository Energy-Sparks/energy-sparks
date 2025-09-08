class AddDisableNormalisationToeToComparisonCustomPeriods < ActiveRecord::Migration[7.2]
  def change
    add_column :comparison_custom_periods, :disable_normalisation, :boolean, default: false, null: false
  end
end
