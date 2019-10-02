class AddAlertColourToFindOutMoreType < ActiveRecord::Migration[5.2]
  def change
    add_column :find_out_more_type_content_versions, :colour, :integer, default: 0, null: false
  end
end
