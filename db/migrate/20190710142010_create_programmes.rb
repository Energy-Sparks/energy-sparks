class CreateProgrammes < ActiveRecord::Migration[6.0]
  def change
    create_table :programmes do |t|
      t.references  :programme_type,  foreign_key: { on_delete: :cascade }
      t.references  :school,          foreign_key: { on_delete: :cascade }
      t.integer     :status, null: false, default: 0
      t.date        :started_on
      t.date        :ended_on
      t.text        :title
    end
  end
end
