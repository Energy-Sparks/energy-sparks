class AddManualReadsToMeters < ActiveRecord::Migration[7.2]
  def change
    add_column :meters, :manual_reads, :boolean, default: false, null: false
  end
end
