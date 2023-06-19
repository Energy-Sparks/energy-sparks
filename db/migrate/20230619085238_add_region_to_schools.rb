class AddRegionToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :region, :integer
  end
end
