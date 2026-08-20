# frozen_string_literal: true

class RemoveTableDataFromAlert < ActiveRecord::Migration[8.1]
  def change
    remove_column :alerts, :table_data, :json
  end
end
