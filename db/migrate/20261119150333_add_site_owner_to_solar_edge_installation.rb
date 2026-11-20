# frozen_string_literal: true

class AddSiteOwnerToSolarEdgeInstallation < ActiveRecord::Migration[8.1]
  def change
    change_table :solar_edge_installations, bulk: true do |t|
      t.string :site_owner_name
      t.string :site_owner_email
    end

    add_index :solar_edge_installations, :site_id, unique: true
  end
end
