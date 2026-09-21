# frozen_string_literal: true

class AddActivityReclassificationModels < ActiveRecord::Migration[8.1]
  def change
    create_enum :locale, %w[en cy]

    create_table :countries do |t|
      # in model
      # translates :name, type: :string, fallbacks: { cy: :en }
      # translates :abbreviation, type: :string, fallbacks: { cy: :en }
      t.enum :locale

      # t.string :name
      # t.string :abbreviation
      t.timestamps
    end

    # Currently we have school_key_stages and activity_type_key_stages
    # So need to look at replacing these, if this is what we would like to do
    # Eng: KS1 KS2 KS3 KS4 KS5
    # Wales: PS1 PS2 PS3 PS4 PS5
    # Scotland: 1st Level, 2nd Level, 3rd Level, 4th Level, Senior Phase
    create_table :learning_stages do |t|
      # these need to be translatable, so add to model
      # t.string :abbreviation # KS1, PS1, 1st Level
      # t.string :name # Key stage One, Progression Step 1, First Level
      t.timestamps
      t.references :country, null: false, foreign_key: { to_table: :countries }
    end

    create_table :activity_topics, &:timestamps

    create_table :activity_subject_areas do |t|
      t.timestamps
      t.references :country, null: false, foreign_key: { to_table: :countries }
    end
  end
end
