class AddCountryAndFundingStatusToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :country, :integer, default: 0, null: false
    add_column :schools, :funding_status, :integer, default: 0, null: false
  end
end
