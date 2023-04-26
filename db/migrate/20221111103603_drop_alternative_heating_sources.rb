class DropAlternativeHeatingSources < ActiveRecord::Migration[6.0]
  def change
    drop_table :alternative_heating_sources
  end
end
