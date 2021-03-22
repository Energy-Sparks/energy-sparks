class CreateMeterReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :meter_reviews do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :consent_grant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
