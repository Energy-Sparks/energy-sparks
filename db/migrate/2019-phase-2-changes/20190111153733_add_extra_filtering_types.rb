class AddExtraFilteringTypes < ActiveRecord::Migration[5.2]
  def change

    create_table :subjects do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :topics do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :impacts do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :activity_timings do |t|
      t.string :name, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :activity_type_subjects, id: false do |t|
      t.references :activity_type, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.references :subject, null: false, foreign_key: {on_delete: :restrict}, index: true
    end

    create_table :activity_type_topics, id: false do |t|
      t.references :activity_type, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.references :topic, null: false, foreign_key: {on_delete: :restrict}, index: true
    end

    create_table :activity_type_impacts, id: false do |t|
      t.references :activity_type, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.references :impact, null: false, foreign_key: {on_delete: :restrict}, index: true
    end

    create_table :activity_type_timings, id: false do |t|
      t.references :activity_type, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.references :activity_timing, null: false, foreign_key: {on_delete: :restrict}, index: true
    end

  end
end
