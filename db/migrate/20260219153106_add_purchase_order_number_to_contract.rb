class AddPurchaseOrderNumberToContract < ActiveRecord::Migration[7.2]
  def change
    add_column :commercial_contracts, :purchase_order_number, :string
  end
end
