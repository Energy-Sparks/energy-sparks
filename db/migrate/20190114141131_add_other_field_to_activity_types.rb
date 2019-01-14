class AddOtherFieldToActivityTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_types, :other, :boolean, default: false
  end
end
