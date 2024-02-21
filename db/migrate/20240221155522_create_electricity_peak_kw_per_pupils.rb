class CreateElectricityPeakKwPerPupils < ActiveRecord::Migration[6.1]
  def change
    create_view :electricity_peak_kw_per_pupils
  end
end
