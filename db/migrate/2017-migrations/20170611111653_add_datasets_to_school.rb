class AddDatasetsToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :gas_dataset, :string
    add_column :schools, :electricity_dataset, :string
  end
end
