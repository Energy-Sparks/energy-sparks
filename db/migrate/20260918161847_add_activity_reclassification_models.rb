# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength

class AddActivityReclassificationModels < ActiveRecord::Migration[8.1]
  def change
    # school and school group already use an integer enum for country
    # but we want to use a string enum for the new models
    create_enum :country, %w[england scotland wales]

    create_enum :task_label_types, %w[aim duration topic focus]

    create_table :task_labels do |t|
      t.enum 'label_type', null: false, enum_type: 'task_label_types'
      t.timestamps
    end

    create_table :task_label_items do |t|
      t.references :task, polymorphic: true, null: false, index: true
      t.references :label, null: false,
                           foreign_key: { to_table: :task_labels }
      t.timestamps
      t.index %i[task_type task_id label_id], unique: true
    end

    # Should be more widely used, so keep out of activities module
    # Look to using this in School model in the future
    create_table :learning_stages do |t|
      t.enum 'country', default: 'england', null: false, enum_type: 'country'

      t.timestamps
    end

    create_table :activities_subject_areas do |t|
      t.enum 'country', default: 'england', null: false, enum_type: 'country'

      t.timestamps
    end

    create_table :activities_activity_type_learning_stages do |t|
      t.references :activity_type, null: false,
                                   foreign_key: { to_table: :activity_types }
      t.references :learning_stage, null: false,
                                    foreign_key: { to_table: :learning_stages }
      t.timestamps
      t.index %i[activity_type_id learning_stage_id], unique: true
    end

    create_table :activities_activity_type_subject_areas do |t|
      t.references :activity_type, null: false,
                                   foreign_key: { to_table: :activity_types }
      t.references :subject_area, null: false,
                                  foreign_key: { to_table: :activities_subject_areas }
      t.timestamps
      t.index %i[activity_type_id subject_area_id], unique: true
    end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
