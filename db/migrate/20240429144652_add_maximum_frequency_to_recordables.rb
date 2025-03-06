class AddMaximumFrequencyToRecordables < ActiveRecord::Migration[6.1]
  def change
    add_column :activity_types, :maximum_frequency, :integer, default: 10
    add_column :intervention_types, :maximum_frequency, :integer, default: 10
  end
end
