class AddIndexOnSashIdToSchools < ActiveRecord::Migration[5.0]
  def change
    add_index :schools, :sash_id
  end
end
