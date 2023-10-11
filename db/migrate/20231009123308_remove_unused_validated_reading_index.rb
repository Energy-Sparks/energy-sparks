class RemoveUnusedValidatedReadingIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index 'amr_validated_readings', column: [:meter_id], name: 'index_amr_validated_readings_on_meter_id'
  end
end
