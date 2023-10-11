class CreateTransportSurveys < ActiveRecord::Migration[6.0]
  def change
    create_table :transport_surveys do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.date :run_on, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
