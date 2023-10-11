class AddOwnedByToNotes < ActiveRecord::Migration[6.0]
  def change
    add_reference :notes, :owned_by, foreign_key: { to_table: :users }
  end
end
