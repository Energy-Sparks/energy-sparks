class CreateEstablishmentLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :lists_establishment_links, primary_key: [:urn, :link_urn] do |t|
      t.integer   :urn
      t.integer   :link_urn
      t.string    :link_name
      t.string    :link_type
      t.datetime  :link_established_date

      t.timestamps
    end
  end
end
