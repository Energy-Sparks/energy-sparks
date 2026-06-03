class MigratePupilPassword < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :pupil_password, :pupil_password_old
    add_column :users, :pupil_password, :string
  end
end
