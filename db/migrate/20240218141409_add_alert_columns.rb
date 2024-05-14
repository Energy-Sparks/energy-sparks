class AddAlertColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :alerts, :variables, :jsonb
    add_column :alerts, :report_period, :integer
  end
end
