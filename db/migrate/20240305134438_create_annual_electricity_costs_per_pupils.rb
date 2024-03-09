class CreateAnnualElectricityCostsPerPupils < ActiveRecord::Migration[6.1]
  def change
    create_view :annual_electricity_costs_per_pupils
  end
end
