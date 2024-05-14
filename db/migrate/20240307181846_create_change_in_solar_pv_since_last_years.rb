class CreateChangeInSolarPvSinceLastYears < ActiveRecord::Migration[6.1]
  def change
    create_view :change_in_solar_pv_since_last_years
  end
end
