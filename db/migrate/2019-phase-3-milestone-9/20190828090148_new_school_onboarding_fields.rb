class NewSchoolOnboardingFields < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :has_solar_panels, :boolean, default: false, null: false
    add_column :schools, :has_swimming_pool, :boolean, default: false, null: false
    add_column :schools, :serves_dinners, :boolean, default: false, null: false
    add_column :schools, :cooks_dinners_onsite, :boolean, default: false, null: false
    add_column :schools, :cooks_dinners_for_other_schools, :boolean, default: false, null: false
    add_column :schools, :cooks_dinners_for_other_schools_count, :integer, default: nil
  end
end
