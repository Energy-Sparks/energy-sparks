# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength

class AddActivityReclassificationModels < ActiveRecord::Migration[8.1]
  def change
    # school and school group already use an integer enum for country
    # but we should move to this? or a countries table
    create_enum :country, %w[england scotland wales]
    # create_table :country do |t|
    ## in model if we were to use this method
    ## translates :name, type: :string, fallbacks: { cy: :en }
    ## translates :abbreviation, type: :string, fallbacks: { cy: :en }
    # t.timestamps
    # end

    # In the spirit of trying to group tables / models together,
    # keep everything namespaced under /tasks (/activities felt too confusing)
    # Is still a bit of a mounthfull but this is the best option I have come up with at the mo

    create_table :tasks_aims, &:timestamps
    create_table :tasks_durations, &:timestamps

    # Not always activity specific. so keep out of tasks module
    create_table :learning_stages do |t|
      t.enum 'country', default: 'england', null: false, enum_type: 'country'
      # t.references :country, null: false, foreign_key: { to_table: :countries }

      t.timestamps
    end

    create_table :tasks_subject_areas do |t|
      t.enum 'country', default: 'england', null: false, enum_type: 'country'
      # t.references :country, null: false, foreign_key: { to_table: :countries }

      t.timestamps
    end

    create_table :tasks_topics, &:timestamps

    create_table :tasks_activity_type_aims do |t|
      t.references :activity_type, null: false,
                                   foreign_key: { to_table: :activity_types }
      t.references :aim, null: false,
                         foreign_key: { to_table: :tasks_aims }
      t.timestamps
      t.index %i[activity_type_id aim_id], unique: true
    end

    create_table :tasks_activity_type_durations do |t|
      t.references :activity_type, null: false,
                                   foreign_key: { to_table: :activity_types }
      t.references :duration, null: false,
                              foreign_key: { to_table: :tasks_durations }
      t.timestamps
      t.index %i[activity_type_id duration_id], unique: true
    end

    create_table :tasks_activity_type_learning_stages do |t|
      t.references :activity_type, null: false,
                                   foreign_key: { to_table: :activity_types }
      t.references :learning_stage, null: false,
                                    foreign_key: { to_table: :learning_stages }
      t.timestamps
      t.index %i[activity_type_id learning_stage_id], unique: true
    end

    create_table :tasks_activity_type_subject_areas do |t|
      t.references :activity_type, null: false,
                                   foreign_key: { to_table: :activity_types }
      t.references :subject_area, null: false,
                                  foreign_key: { to_table: :tasks_subject_areas }
      t.timestamps
      t.index %i[activity_type_id subject_area_id], unique: true
    end

    create_table :tasks_activity_type_topics do |t|
      t.references :activity_type, null: false,
                                   foreign_key: { to_table: :activity_types }
      t.references :topic, null: false,
                           foreign_key: { to_table: :tasks_topics }
      t.timestamps
      t.index %i[activity_type_id topic_id], unique: true
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
