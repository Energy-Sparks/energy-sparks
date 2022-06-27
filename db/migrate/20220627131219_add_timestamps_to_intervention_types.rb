class AddTimestampsToInterventionTypes < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :intervention_types, null: false, default: -> { 'NOW()' }
  end
end
