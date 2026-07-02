# frozen_string_literal: true

class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.string :name, index: { unique: true }
      t.integer :owned_by_id
      t.timestamps
    end
    add_reference :meters, :supplier
  end
end
