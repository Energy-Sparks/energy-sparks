class AddIndexForReadingDate < ActiveRecord::Migration[5.2]
  def change
    add_index(:amr_validated_readings, :reading_date)
  end
end
