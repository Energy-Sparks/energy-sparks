class AddUniquenessToIdentifierAndDescription < ActiveRecord::Migration[6.0]
  def change
    add_index :amr_data_feed_configs, :identifier, unique: true
    add_index :amr_data_feed_configs, :description, unique: true
  end
end
