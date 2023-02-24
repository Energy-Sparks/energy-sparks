class AddCountryToSchoolGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :country, :integer, default: 0, null: false
  end
end
