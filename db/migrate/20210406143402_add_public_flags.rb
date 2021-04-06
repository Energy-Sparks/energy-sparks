class AddPublicFlags < ActiveRecord::Migration[6.0]
  def change
    add_column :schools,       :public, :boolean, default: true
    add_column :school_groups, :public, :boolean, default: true
    add_column :scoreboards,   :public, :boolean, default: true
  end
end
