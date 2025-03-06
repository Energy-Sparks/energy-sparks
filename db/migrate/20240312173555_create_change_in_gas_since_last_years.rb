class CreateChangeInGasSinceLastYears < ActiveRecord::Migration[6.1]
  def change
    create_view :change_in_gas_since_last_years
  end
end
