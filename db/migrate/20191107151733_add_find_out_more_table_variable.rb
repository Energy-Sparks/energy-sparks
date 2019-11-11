class AddFindOutMoreTableVariable < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_type_rating_content_versions, :find_out_more_table_variable, :text, default: "none"
  end
end
