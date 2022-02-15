class AddClimateReportingDefaults < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :default_chart_preference, :integer, default: 0, null: false
    add_column :school_onboardings, :default_chart_preference, :integer, default: 0, null: false
    add_column :schools, :chart_preference, :integer, default: 0, null: false
  end
end
