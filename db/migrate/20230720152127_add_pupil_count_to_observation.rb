class AddPupilCountToObservation < ActiveRecord::Migration[6.0]
  def change
    add_column :observations, :pupil_count, :integer, default: nil
  end
end
