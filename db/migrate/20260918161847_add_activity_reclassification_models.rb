# frozen_string_literal: true

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

    # not always activity specific
    create_table :learning_stages do |t|
      t.enum 'country', default: 'england', null: false, enum_type: 'country'
      # t.references :country, null: false, foreign_key: { to_table: :countries }

      t.timestamps
    end

    create_table :activity_subjects do |t|
      t.enum 'country', default: 'england', null: false, enum_type: 'country'
      # t.references :country, null: false, foreign_key: { to_table: :countries }

      t.timestamps
    end

    create_table :activity_aims, &:timestamps

    create_table :activity_topics, &:timestamps

    create_table :activity_durations, &:timestamps

    create_table :activity_type_topics do |t|
      t.index %i[activity_type_id topic_id], unique: true
    end

    create_table :activity_type_subject_areas do |t|
      t.index %i[activity_type_id activity_subject_area_id], unique: true
    end

    create_table :activity_type_learning_stages do |t|
      t.index %i[activity_type_id activities_learning_stage_id], unique: true
    end

    create_table :activity_type_aims do |t|
      t.index %i[activity_type_id activity_aim_id], unique: true
    end
  end
end
