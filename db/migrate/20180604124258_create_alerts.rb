class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.references  :alert_type, foreign_key: true
      t.references  :school,     foreign_key: true
    end
  end
end
