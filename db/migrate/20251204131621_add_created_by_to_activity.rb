class AddCreatedByToActivity < ActiveRecord::Migration[7.2]
  def change
    add_reference :activities, :created_by, foreign_key: { to_table: :users }
  end
end
