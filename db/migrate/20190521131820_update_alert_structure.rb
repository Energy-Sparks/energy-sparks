class UpdateAlertStructure < ActiveRecord::Migration[6.0]
  def up
    add_column :alerts, :template_data, :json, default: {}
    add_column :alerts, :table_data, :json, default: {}
    add_column :alerts, :chart_data, :json, default: {}
    add_column :alerts, :rating, :decimal

    connection.execute "UPDATE alerts SET rating = (data#>>'{template_data,rating}')::decimal WHERE data#>'{template_data,rating}' IS NOT NULL"
    connection.execute "UPDATE alerts SET template_data = data->'template_data' WHERE data->'template_data' IS NOT NULL"
    connection.execute "UPDATE alerts SET chart_data = data->'chart_data' WHERE data->'chart_data' IS NOT NULL"
    connection.execute "UPDATE alerts SET table_data = data->'table_data' WHERE data->'table_data' IS NOT NULL"

    remove_column :alerts, :data
    remove_column :alerts, :summary

    connection.execute "DELETE FROM alerts WHERE rating IS NULL"
  end
end
