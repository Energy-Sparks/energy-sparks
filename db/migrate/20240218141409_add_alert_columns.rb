class AddAlertColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :alerts, :variables, :json
    add_column :alerts, :variables_cy, :json
  end
end
