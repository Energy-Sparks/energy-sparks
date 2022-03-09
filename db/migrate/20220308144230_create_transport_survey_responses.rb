class CreateTransportSurveyResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :transport_survey_responses do |t|
      t.references :transport_survey, null: false, foreign_key:  {on_delete: :cascade}
      t.references :transport_type, null: false, foreign_key: true
      t.string :device_identifier, null: false
      t.datetime :surveyed_at, null: false
      t.integer :journey_minutes, null: false, default: 0
      t.column :weather, :integer, null: false, default: 0

      t.timestamps
    end
  end
end
