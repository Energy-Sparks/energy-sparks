class AddNameToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :name, :string
  end
end
