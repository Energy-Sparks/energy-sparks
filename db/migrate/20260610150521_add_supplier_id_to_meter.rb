# frozen_string_literal: true

class AddSupplierIdToMeter < ActiveRecord::Migration[8.1]
  def change
    add_column :meters, :supplier_id, :integer
    add_index :meters, :supplier_id
  end
end
