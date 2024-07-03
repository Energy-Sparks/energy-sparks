class RemoveSchoolGroupFunder < ActiveRecord::Migration[7.0]
  def change
    remove_reference :school_groups, :funder
  end
end
