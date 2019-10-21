class CreateSchoolAlertTypeException < ActiveRecord::Migration[6.0]
  def change
    create_table :school_alert_type_exceptions do |t|
      t.references  :alert_type,  foreign_key: { on_delete: :cascade }
      t.references  :school,      foreign_key: { on_delete: :cascade }
      t.text        :reason
      t.timestamps
    end
  end
end
