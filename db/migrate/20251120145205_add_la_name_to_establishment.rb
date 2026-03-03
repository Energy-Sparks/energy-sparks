class AddLaNameToEstablishment < ActiveRecord::Migration[7.2]
  def change
    add_column :lists_establishments, :la_name, :string
  end
end
