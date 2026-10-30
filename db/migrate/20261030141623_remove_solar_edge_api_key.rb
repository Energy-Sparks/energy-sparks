# frozen_string_literal: true

class RemoveSolarEdgeApiKey < ActiveRecord::Migration[8.1]
  def change
    remove_column :solar_edge_installations, :api_key, :text
  end
end
