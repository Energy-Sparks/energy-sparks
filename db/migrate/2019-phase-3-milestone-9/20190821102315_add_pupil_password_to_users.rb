class AddPupilPasswordToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :pupil_password, :string
    add_index :users, [:school_id, :pupil_password], unique: true
  end
end
