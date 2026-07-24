# frozen_string_literal: true

class AddHasBatteryToSchools < ActiveRecord::Migration[8.1]
  def change
    add_column :schools, :has_battery, :boolean, default: false, null: false
  end
end
