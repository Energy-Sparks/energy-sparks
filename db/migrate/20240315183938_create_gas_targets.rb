class CreateGasTargets < ActiveRecord::Migration[6.1]
  def change
    create_view :gas_targets
  end
end
