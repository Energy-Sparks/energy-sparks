# frozen_string_literal: true

class ChangeXeroAccountCodeToString < ActiveRecord::Migration[8.1]
  def up
    add_column :commercial_xero_account_codes, :code_str, :string

    execute <<~SQL.squish
      UPDATE commercial_xero_account_codes
      SET code_str = code::text;
    SQL

    remove_column :commercial_xero_account_codes, :code
    rename_column :commercial_xero_account_codes, :code_str, :code
    add_index :commercial_xero_account_codes, :code, unique: true
  end

  def down
    add_column :commercial_xero_account_codes, :code_int, :integer

    execute <<~SQL.squish
      UPDATE commercial_xero_account_codes
      SET code_int = code::integer;
    SQL

    remove_column :commercial_xero_account_codes, :code
    rename_column :commercial_xero_account_codes, :code_int, :code
    add_index :commercial_xero_account_codes, :code, unique: true
  end
end
