class CreateEstablishmentLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :lists_establishment_links, primary_key: [:establishment_id, :linked_establishment_id] do |t|
      t.string    :link_name
      t.string    :link_type
      t.datetime  :link_established_date

      t.belongs_to :establishment, index: true
      t.belongs_to :linked_establishment, index: true

      t.timestamps
    end
  end
end
