class CreateSchoolGroupClusters < ActiveRecord::Migration[6.0]
  def change
    create_table :school_group_clusters do |t|
      t.string :name
      t.references :school_group, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    create_table :school_group_cluster_schools do |t|
      t.references :school_group_cluster, null: false, foreign_key: { on_delete: :cascade }
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
