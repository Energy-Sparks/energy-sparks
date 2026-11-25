# frozen_string_literal: true

class AddPositionToLearningStages < ActiveRecord::Migration[8.1]
  def change
    add_column :learning_stages, :position, :integer, default: 0, null: false
  end
end
