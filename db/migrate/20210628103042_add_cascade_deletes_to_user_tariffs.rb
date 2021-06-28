class AddCascadeDeletesToUserTariffs < ActiveRecord::Migration[6.0]
  def up
    # remove any old prices or charges that no longer have user tariffs
    # see https://repository.prace-ri.eu/git/help/development/database/add_foreign_key_to_existing_column.md
    UserTariffPrice.where('user_tariff_id NOT IN (SELECT id FROM user_tariffs)').in_batches do |relation|
      relation.delete_all
    end
    UserTariffCharge.where('user_tariff_id NOT IN (SELECT id FROM user_tariffs)').in_batches do |relation|
      relation.delete_all
    end
    add_foreign_key :user_tariff_prices, :user_tariffs, on_delete: :cascade
    add_foreign_key :user_tariff_charges, :user_tariffs, on_delete: :cascade
  end

  def down
  end
end
