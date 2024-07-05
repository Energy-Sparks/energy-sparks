class AddArchivedDateToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :archived_date, :date
  end
end
