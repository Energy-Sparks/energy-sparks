class AddRelevanceToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :relevance, :integer, default: 0
  end
end
