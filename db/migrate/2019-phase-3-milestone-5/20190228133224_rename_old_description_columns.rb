class RenameOldDescriptionColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :activities,     :description, :deprecated_description
    rename_column :activity_types, :description, :deprecated_description
  end
end
