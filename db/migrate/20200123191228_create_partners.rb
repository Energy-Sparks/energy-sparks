class CreatePartners < ActiveRecord::Migration[6.0]
  def change
    create_table :partners do |t|
      t.integer :position, null: false, default: 0
      t.text    :url
      t.timestamps
    end
  end
end
