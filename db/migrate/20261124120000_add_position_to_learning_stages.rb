# frozen_string_literal: true

class AddPositionToLearningStages < ActiveRecord::Migration[8.1]
  SCOTTISH_POSITIONS = {
    'First Level' => 1,
    'Second Level' => 2,
    'Third Level' => 3,
    'Fourth Level' => 4,
    'Senior Phase' => 5
  }.freeze

  def up
    add_column :learning_stages, :position, :integer, default: 0, null: false

    SCOTTISH_POSITIONS.each do |name, position|
      LearningStage.i18n.where(name: name).first&.update!(position: position)
    end
  end

  def down
    remove_column :learning_stages, :position
  end
end
