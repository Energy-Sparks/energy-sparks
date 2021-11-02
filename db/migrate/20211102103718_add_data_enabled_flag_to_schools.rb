class AddDataEnabledFlagToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :data_enabled, :boolean, default: true
  end
end
