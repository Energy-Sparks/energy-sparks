class UpdateProgrammesWithStartDates < ActiveRecord::Migration[6.0]
  def up
    connection.execute('UPDATE programmes SET started_on = NOW() WHERE started_on IS NULL')
    change_column_null :programmes, :started_on, false
  end

  def down
    change_column_null :programmes, :started_on, true
  end
end
