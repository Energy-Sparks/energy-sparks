class CreateSolarPvBenefitEstimates < ActiveRecord::Migration[6.1]
  def change
    create_view :solar_pv_benefit_estimates
  end
end
