# frozen_string_literal: true

class AddXeroAccountCode < ActiveRecord::Migration[8.1]
  def change
    create_table :commercial_xero_account_codes do |t|
      t.integer :code, null: false, index: { unique: true }
      t.string :label, null: false
      t.timestamps
    end
    add_reference :commercial_contracts, :xero_account_code, foreign_key: { to_table: :commercial_xero_account_codes }
  end
end
