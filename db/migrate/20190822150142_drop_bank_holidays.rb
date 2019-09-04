class DropBankHolidays < ActiveRecord::Migration[6.0]
  def change
    drop_table :bank_holidays
  end
end
