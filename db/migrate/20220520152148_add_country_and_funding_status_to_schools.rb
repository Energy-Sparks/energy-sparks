class AddCountryAndFundingStatusToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :country, :integer
    add_column :schools, :funding_status, :integer
  end
end
