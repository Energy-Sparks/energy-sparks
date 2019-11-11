class CreateAlertErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :alert_errors do |t|
      t.references :school
      t.references :alert_generation_run
      t.references :alert_type
      t.date       :asof_date
      t.text       :information
      t.timestamps
    end
  end
end
