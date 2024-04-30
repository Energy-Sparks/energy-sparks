# frozen_string_literal: true

class ChangeAlertReportPeriod < ActiveRecord::Migration[6.1]
  def change
    change_table :alerts, bulk: true do |t|
      t.rename :report_period, :reporting_period # enum
      t.references :custom_period, foreign_key: { to_table: 'comparison_custom_periods', on_delete: :cascade }
    end
  end
end
