class AddClimateReportingDefaults < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :default_prefer_climate_reporting, :boolean, default: false
    add_column :school_onboardings, :default_prefer_climate_reporting, :boolean, default: false
    add_column :schools, :prefer_climate_reporting, :boolean, default: false
  end
end
