class AddInvolvedPupilsToObservation < ActiveRecord::Migration[6.0]
  def change
    add_column :observations, :involved_pupils, :boolean, null: false, default: false
  end
end
