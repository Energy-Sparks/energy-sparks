# frozen_string_literal: true

class CreateImpactStatement < ActiveRecord::Migration[8.1]
  def change # rubocop:disable Metrics/AbcSize
    create_table :impact_report_organisation_statements do |t|
      t.string :academic_year, null: false, index: { unique: true }
      t.boolean :current, null: false, default: false
      t.integer :schools, null: false, default: 0
      t.integer :pupils, null: false, default: 0
      t.integer :staff, null: false, default: 0
      t.integer :activities, null: false, default: 0
      t.integer :actions, null: false, default: 0
      t.integer :total_cost_savings, null: false, default: 0
      t.integer :total_carbon_savings, null: false, default: 0
      t.integer :average_primary_saving, null: false, default: 0
      t.integer :average_secondary_saving, null: false, default: 0
      t.integer :best_saving, null: false, default: 0
      t.integer :primary_saving_electricity, null: false, default: 0
      t.integer :primary_saving_gas, null: false, default: 0
      t.integer :primary_cost_saving, null: false, default: 0
      t.integer :primary_carbon_saving, null: false, default: 0
      t.integer :secondary_saving_electricity, null: false, default: 0
      t.integer :secondary_saving_gas, null: false, default: 0
      t.integer :secondary_cost_saving, null: false, default: 0
      t.integer :secondary_carbon_saving, null: false, default: 0
      t.timestamps
    end
  end
end
