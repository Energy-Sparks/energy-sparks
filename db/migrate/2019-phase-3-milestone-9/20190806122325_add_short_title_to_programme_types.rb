class AddShortTitleToProgrammeTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :programme_types, :short_description, :text
  end
end
