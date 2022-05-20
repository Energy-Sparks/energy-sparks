class AddCountryAndFundingStatusToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :country, :string
    add_column :schools, :funding_status, :string
  end
end
