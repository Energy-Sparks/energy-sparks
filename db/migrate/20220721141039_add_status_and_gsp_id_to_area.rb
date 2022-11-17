class AddStatusAndGspIdToArea < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :gsp_id, :integer, null: true
    add_column :areas, :active, :boolean, default: true
  end
end
