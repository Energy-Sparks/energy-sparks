class AddTargetsFeatureFlagToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :enable_targets_feature, :boolean, default: true
  end
end
