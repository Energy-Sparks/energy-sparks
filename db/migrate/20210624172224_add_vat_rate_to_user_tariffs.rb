class AddVatRateToUserTariffs < ActiveRecord::Migration[6.0]
  def change
    add_column :user_tariffs, :vat_rate, :string, default: nil
  end
end
