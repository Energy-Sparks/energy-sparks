class CreateAnnualStorageHeaterOutOfHoursUses < ActiveRecord::Migration[6.1]
  def change
    create_view :annual_storage_heater_out_of_hours_uses
  end
end
