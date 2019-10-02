class CreateObservations < ActiveRecord::Migration[6.0]
  def change
    create_table :observations do |t|
      t.references  :school,      null: false, foreign_key: { on_delete: :cascade }
      t.datetime    :at,          null: false
      t.text        :description
      t.timestamps
    end
  end
end
