class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.references  :school
      t.references  :alert_type
      t.date        :run_on
      t.text        :status
      t.text        :summary
      t.json        :data,          default: {}
      t.boolean     :acknowledged,  default: false
      t.timestamps
    end
  end
end
