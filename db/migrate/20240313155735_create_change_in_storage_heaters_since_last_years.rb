class CreateChangeInStorageHeatersSinceLastYears < ActiveRecord::Migration[6.1]
  def change
    create_view :change_in_storage_heaters_since_last_years
  end
end
