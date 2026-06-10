# frozen_string_literal: true

class CreateInvoicingModels < ActiveRecord::Migration[8.1]
  def change
    create_table :commercial_invoices do |t|
      t.references :contract, null: false, foreign_key: { to_table: :commercial_contracts }
      t.string :purchase_order_number
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    create_table :commercial_line_items do |t|
      t.references :invoice, null: false, foreign_key: { to_table: :commercial_invoices }
      t.references :licence, null: false, foreign_key: { to_table: :commercial_licences }

      t.boolean :private_account, null: false, default: false
      t.integer :number_of_meters, null: false, default: 0
      t.decimal :private_account_fee, null: false, precision: 10, scale: 2
      t.decimal :metering_fee, null: false, precision: 10, scale: 2
      t.decimal :base_price, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
