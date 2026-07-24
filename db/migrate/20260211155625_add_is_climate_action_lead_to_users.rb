class AddIsClimateActionLeadToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :climate_action_lead, :boolean, default: false, null: false
  end
end
