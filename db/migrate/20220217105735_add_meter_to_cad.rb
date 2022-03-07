class AddMeterToCad < ActiveRecord::Migration[6.0]
  def change
    add_reference :cads, :meter, null: true, foreign_key: true
  end
end
