class AddDefaultCountryToSchoolGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :default_country, :integer, default: 0, null: false
  end
end
