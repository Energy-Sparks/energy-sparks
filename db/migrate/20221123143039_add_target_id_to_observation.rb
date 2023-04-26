class AddTargetIdToObservation < ActiveRecord::Migration[6.0]
  def change
    add_reference :observations, :school_target
    add_foreign_key :observations, :school_targets
  end
end
