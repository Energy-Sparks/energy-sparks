class RemoveUniquenessFromSchoolUrns < ActiveRecord::Migration[6.0]
  def up
    remove_index :schools, :urn
    add_index :schools, :urn, unique: false
  end

  def down
    remove_index :schools, :urn
    add_index :schools, :urn, unique: true
  end
end
