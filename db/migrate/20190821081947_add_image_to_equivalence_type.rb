class AddImageToEquivalenceType < ActiveRecord::Migration[6.0]
  def change
    add_column :equivalence_types, :image_name, :integer, default: 0, null: false
  end
end
