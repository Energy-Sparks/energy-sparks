class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.references  :school
      t.references  :alert_type
      t.date        :run_on
      t.integer     :status
      t.text        :summary
      t.json        :data,          default: {}
      t.timestamps
    end
  end
end
