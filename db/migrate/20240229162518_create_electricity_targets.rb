class CreateElectricityTargets < ActiveRecord::Migration[6.1]
  def change
    create_view :electricity_targets
  end
end
