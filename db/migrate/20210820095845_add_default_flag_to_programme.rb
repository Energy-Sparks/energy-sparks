class AddDefaultFlagToProgramme < ActiveRecord::Migration[6.0]
  def change
    add_column :programme_types, :default, :boolean, default: false
  end
end
