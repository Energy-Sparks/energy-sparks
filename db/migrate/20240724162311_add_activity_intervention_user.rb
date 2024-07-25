class AddActivityInterventionUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :activities, :user, foreign_key: { to_table: :users }
    add_reference :observations, :user, foreign_key: { to_table: :users }
  end
end
