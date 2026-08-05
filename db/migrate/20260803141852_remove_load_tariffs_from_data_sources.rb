# frozen_string_literal: true

class RemoveLoadTariffsFromDataSources < ActiveRecord::Migration[8.1]
  def change
    remove_column :data_sources, :load_tariffs, :boolean
  end
end
