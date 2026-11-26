# frozen_string_literal: true

class AddPositionToLearningStages < ActiveRecord::Migration[8.1]
  POSITIONS = {
    england: {
      'Key Stage 1' => 1,
      'Key Stage 2' => 2,
      'Key Stage 3' => 3,
      'Key Stage 4' => 4,
      'Key Stage 5' => 5
    },
    scotland: {
      'First Level' => 1,
      'Second Level' => 2,
      'Third Level' => 3,
      'Fourth Level' => 4,
      'Senior Phase' => 5
    },
    wales: {
      'Progression Step 1' => 1,
      'Progression Step 2' => 2,
      'Progression Step 3' => 3,
      'Progression Step 4' => 4,
      'Progression Step 5' => 5
    }
  }.freeze

  def up
    add_column :learning_stages, :position, :integer, default: 0, null: false

    POSITIONS.each do |country, positions|
      positions.each do |name, position|
        LearningStage.i18n.where(country:, name:).first&.update!(position:)
      end
    end
  end

  def down
    remove_column :learning_stages, :position
  end
end
