class UpdateAlertStructure < ActiveRecord::Migration[6.0]
  def up
    add_column :alerts, :template_data, :json, default: {}
    add_column :alerts, :table_data, :json, default: {}
    add_column :alerts, :chart_data, :json, default: {}
    add_column :alerts, :rating, :decimal

    connection.execute "UPDATE alerts SET rating = (data#>>'{template_data,rating}')::decimal WHERE data#>'{template_data,rating}' IS NOT NULL"
    # we don't have the rating in the template for holiday alerts
    connection.execute "UPDATE alerts SET rating = (data#>>'{rating}')::decimal WHERE data#>'{template_data,holiday_start_date}' IS NOT NULL"
    connection.execute "UPDATE alerts SET template_data = data->'template_data' WHERE data->'template_data' IS NOT NULL"
    connection.execute "UPDATE alerts SET chart_data = data->'chart_data' WHERE data->'chart_data' IS NOT NULL"
    connection.execute "UPDATE alerts SET table_data = data->'table_data' WHERE data->'table_data' IS NOT NULL"
    connection.execute "UPDATE alerts SET status = 0 WHERE data#>>'{template_data,status}' = 'good'"
    connection.execute "UPDATE alerts SET status = 1 WHERE data#>>'{template_data,status}' = 'poor'"
    connection.execute "UPDATE alerts SET status = 2 WHERE data#>>'{template_data,status}' = 'not_enough_data'"
    connection.execute "UPDATE alerts SET status = 3 WHERE data#>>'{template_data,status}' = 'failed'"
    connection.execute "UPDATE alerts SET status = 4 WHERE data#>>'{template_data,status}' = 'bad'"

    remove_column :alerts, :data
    remove_column :alerts, :summary

    connection.execute "DELETE FROM alerts WHERE rating IS NULL"
    connection.execute "DELETE FROM content_generation_runs"
  end
end
