class AddMeritFieldsToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :sash_id, :integer
    add_column :schools, :level, :integer, default: 0
  end
end
