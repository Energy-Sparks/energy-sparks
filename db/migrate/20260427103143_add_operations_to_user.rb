# frozen_string_literal: true

class AddOperationsToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :operations, :boolean, default: false, null: false
  end
end
