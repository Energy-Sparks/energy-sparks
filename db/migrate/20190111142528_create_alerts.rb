class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.references  :school
      t.references  :alert_type
      t.date        :when_run
      t.text        :status
      t.text        :summary
      t.json        :data
      t.boolean     :acknowledged, default: false
    end
  end
end
