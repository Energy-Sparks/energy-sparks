class CreateClusterSchoolsUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :cluster_schools_users, id: false do |t|
      t.references :user, foreign_key: {on_delete: :cascade}
      t.references :school, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
    add_index :cluster_schools_users, [:user_id, :school_id]
  end
end
