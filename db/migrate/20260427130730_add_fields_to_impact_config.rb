# frozen_string_literal: true

class AddFieldsToImpactConfig < ActiveRecord::Migration[8.1]
  def change
    change_table :impact_report_configurations, bulk: true do |t|
      t.boolean :active, default: false, null: false
      t.boolean :show_energy_efficiency, default: true, null: false

      t.references :energy_efficiency_school,
                   foreign_key: { to_table: :schools },
                   index: true

      t.date :energy_efficiency_school_expiry_date
      t.text :energy_efficiency_note

      t.references :engagement_school,
                   foreign_key: { to_table: :schools },
                   index: true

      t.date :engagement_school_expiry_date
      t.text :engagement_note
    end
  end
end
