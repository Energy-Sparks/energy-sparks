class UpdateAlertErrors < ActiveRecord::Migration[6.0]
  def up
    connection.execute "UPDATE alert_errors SET information = concat('INVALID. ', information)"
  end
end
