class CreateHeatingInWarmWeathers < ActiveRecord::Migration[6.1]
  def change
    create_view :heating_in_warm_weathers
  end
end
