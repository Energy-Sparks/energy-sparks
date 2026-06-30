# frozen_string_literal: true

class AddXeroAccountCode < ActiveRecord::Migration[8.1]
  def change
    create_table :commercial_xero_account_codes do |t|
      t.integer :code
      t.string :label
      t.timestamps
    end
    add_reference :commercial_contracts, :xero_account_code, foreign_key: { to_table: :commercial_xero_account_codes }
  end
end
