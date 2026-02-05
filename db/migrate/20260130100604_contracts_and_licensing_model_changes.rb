class ContractsAndLicensingModelChanges < ActiveRecord::Migration[7.2]
  def change
    change_table :commercial_licences, bulk: true do |t|
      t.text :comments
      t.decimal :school_specific_price, precision: 10, scale: 2
    end

    add_column :funders, :invoiced, :boolean, null: false, default: true

    rename_enum_value :contract_licence_period, from: 'one_year', to: 'custom'
    add_column :commercial_contracts, :licence_years, :decimal, precision: 4, scale: 2
  end
end
