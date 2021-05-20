class AddRemovalDateAndActiveFlagToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :active,:boolean, default: true
    add_column :schools, :removal_date,:date
  end
end
