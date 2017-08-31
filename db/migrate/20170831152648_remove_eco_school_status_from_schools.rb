class RemoveEcoSchoolStatusFromSchools < ActiveRecord::Migration[5.0]
  def change
    remove_column :schools, :eco_school_status, :string
  end
end
