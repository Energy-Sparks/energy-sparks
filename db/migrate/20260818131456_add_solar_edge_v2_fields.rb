# frozen_string_literal: true

class AddSolarEdgeV2Fields < ActiveRecord::Migration[8.1]
  def change
    change_table :solar_edge_installations, bulk: true do |t|
      t.string :access_token
      t.datetime :access_token_expires_at
      t.datetime :consent_granted_at
      t.string :renewal_token
    end
  end
end
