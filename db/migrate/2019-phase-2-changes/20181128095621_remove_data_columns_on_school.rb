class RemoveDataColumnsOnSchool < ActiveRecord::Migration[5.2]
  def up
    remove_column :schools, :electricity_dataset
    remove_column :schools, :gas_dataset
  end

  def down
    add_column :schools, :electricity_dataset, :string
    add_column :schools, :gas_dataset, :string
  end
end
