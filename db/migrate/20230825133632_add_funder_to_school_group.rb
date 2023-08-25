class AddFunderToSchoolGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :funder_id, :bigint
  end
end
