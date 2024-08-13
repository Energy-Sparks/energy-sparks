class AddActivityAndObservationUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :observations, :created_by, foreign_key: { to_table: :users }
    add_reference :observations, :updated_by, foreign_key: { to_table: :users }
    add_reference :activities, :updated_by, foreign_key: { to_table: :users }
  end
end
