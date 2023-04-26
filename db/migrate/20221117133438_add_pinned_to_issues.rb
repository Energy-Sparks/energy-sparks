class AddPinnedToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :pinned, :boolean, default: false
  end
end
