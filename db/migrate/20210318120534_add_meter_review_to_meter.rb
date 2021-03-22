class AddMeterReviewToMeter < ActiveRecord::Migration[6.0]
  def change
    add_reference :meters, :meter_review, null: true, foreign_key: true
  end
end
