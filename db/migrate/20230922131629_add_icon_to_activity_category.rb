class AddIconToActivityCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :activity_categories, :icon, :string, default: 'volleyball-ball'
  end
end
