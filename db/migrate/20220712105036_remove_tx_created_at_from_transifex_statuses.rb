class RemoveTxCreatedAtFromTransifexStatuses < ActiveRecord::Migration[6.0]
  def change
    remove_column :transifex_statuses, :tx_created_at, :datetime
  end
end
