class AddDarkSkyAreaToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :dark_sky_area_id, :bigint, index: true
    add_column :school_onboardings, :dark_sky_area_id, :bigint, index: true
    add_column :school_groups, :default_dark_sky_area_id, :bigint, index: true
  end
end
