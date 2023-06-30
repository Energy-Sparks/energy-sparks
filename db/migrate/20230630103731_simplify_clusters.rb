class SimplifyClusters < ActiveRecord::Migration[6.0]
  def change
    add_reference :schools, :school_group_cluster, index: true, foreign_key: { on_delete: :nullify }

    drop_table :school_group_cluster_schools do |t|
      t.references :school_group_cluster, null: false, foreign_key: { on_delete: :cascade }
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
