class AddDccCheckedAtToMeters < ActiveRecord::Migration[6.0]
  def change
    add_column :meters, :dcc_checked_at, :datetime
  end
end
