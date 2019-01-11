class MoveTaggingsAwayFromActsTaggable < ActiveRecord::Migration[5.2]
  def up

    rename_table :tags, :key_stages
    remove_column :key_stages, :taggings_count

    create_table :activity_type_key_stages, id: false do |t|
      t.references :activity_type, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.references :key_stage, null: false, foreign_key: {on_delete: :restrict}, index: true
    end

    create_table :school_key_stages, id: false do |t|
      t.references :school, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.references :key_stage, null: false, foreign_key: {on_delete: :restrict}, index: true
    end

    ActiveRecord::Base.connection.execute(
      "INSERT INTO activity_type_key_stages (key_stage_id, activity_type_id) SELECT tag_id, taggable_id FROM taggings WHERE taggable_type = 'ActivityType'"
    )
    ActiveRecord::Base.connection.execute(
      "INSERT INTO school_key_stages (key_stage_id, school_id) SELECT tag_id, taggable_id FROM taggings WHERE taggable_type = 'School'"
    )

    drop_table :taggings
  end

  def down

    rename_table :key_stages, :tags
    add_column :tags, :taggings_count, :integer, default: 0

    create_table "taggings", force: :cascade do |t|
      t.bigint "tag_id"
      t.string "taggable_type"
      t.bigint "taggable_id"
      t.string "tagger_type"
      t.bigint "tagger_id"
      t.string "context", limit: 128
      t.datetime "created_at"
      t.index ["context"], name: "index_taggings_on_context"
      t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
      t.index ["tag_id"], name: "index_taggings_on_tag_id"
      t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
      t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
      t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
      t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
      t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
      t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    end

    ActiveRecord::Base.connection.execute(
      "INSERT INTO taggings (tag_id, taggable_id, taggable_type, context) SELECT key_stage_id, activity_type_id, 'ActivityType', 'key_stages' FROM activity_type_key_stages"
    )
    ActiveRecord::Base.connection.execute(
      "INSERT INTO taggings (tag_id, taggable_id, taggable_type, context) SELECT key_stage_id, school_id, 'School', 'key_stages' FROM school_key_stages"
    )

    drop_table :activity_type_key_stages
    drop_table :school_key_stages

  end
end
