class AddCountryToSchoolOnboardings < ActiveRecord::Migration[6.0]
  def change
    add_column :school_onboardings, :country, :integer, default: 0, null: false
  end
end
