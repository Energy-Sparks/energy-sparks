class ChangeEnrolledToActive < ActiveRecord::Migration[5.2]
  def change
    rename_column :schools, :enrolled, :active
  end
end
