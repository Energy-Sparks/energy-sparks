class AddDisplayableColumnsToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :displayable, :boolean, null: false, default: true
    add_column :alerts, :analytics_valid, :boolean, null: false, default: true
    add_column :alerts, :enough_data, :integer

    reversible do |dir|
      dir.up do
        connection.execute "UPDATE alerts SET displayable = 'f', analytics_valid = 'f', status = NULL  WHERE status = 5"
        connection.execute "UPDATE alerts SET displayable = 'f' WHERE status IN (2, 3, 5)"
        connection.execute "UPDATE alerts SET displayable = 'f' WHERE status IS NULL"
        connection.execute "UPDATE alerts SET displayable = 'f' WHERE rating IS NULL"
      end
      dir.down do
        connection.execute "UPDATE alerts SET status = 5  WHERE analytics_valid  = 'f'"
      end
    end
  end
end
