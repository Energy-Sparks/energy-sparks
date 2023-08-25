class AddPupilCountToActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :pupil_count, :integer, default: nil
  end
end
