class CreateChangeInEnergyUseSinceJoinedEnergySparks < ActiveRecord::Migration[6.1]
  def change
    create_view :change_in_energy_use_since_joined_energy_sparks
  end
end
