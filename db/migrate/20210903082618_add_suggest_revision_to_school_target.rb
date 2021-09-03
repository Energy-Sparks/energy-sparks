class AddSuggestRevisionToSchoolTarget < ActiveRecord::Migration[6.0]
  def change
    add_column :school_targets, :suggest_revision, :boolean, default: false
    add_column :school_targets, :revised_fuel_types, :string, array: true, null: false, default: []
  end
end
