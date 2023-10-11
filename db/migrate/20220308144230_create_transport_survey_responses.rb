class CreateTransportSurveyResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :transport_survey_responses do |t|
      t.references :transport_survey, null: false, foreign_key: { on_delete: :cascade }
      t.references :transport_type, null: false, foreign_key: true
      t.integer :passengers, :integer, null: false, default: 1
      t.string :run_identifier, null: false
      t.datetime :surveyed_at, null: false
      t.integer :journey_minutes, null: false, default: 0
      t.integer :weather, null: false, default: 0

      t.timestamps
    end
  end
end
