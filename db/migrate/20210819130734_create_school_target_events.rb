class CreateSchoolTargetEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :school_target_events do |t|
      t.references :school, null: false, foreign_key: {on_delete: :cascade}
      t.integer :event, null: false
      t.timestamps
    end
  end
end
