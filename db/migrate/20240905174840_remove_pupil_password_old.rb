class RemovePupilPasswordOld < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :pupil_password_old, :string
  end
end
