class AddDisabledToMeterReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :meter_reviews, :disabled, :boolean, default: false, null: false
  end
end
