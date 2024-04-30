# frozen_string_literal: true

class AddDaysToCustomPeriod < ActiveRecord::Migration[6.1]
  def change
    change_table :comparison_custom_periods, bulk: true do |t|
      t.integer :max_days_out_of_date
      t.integer :enough_days_data
    end
  end
end
