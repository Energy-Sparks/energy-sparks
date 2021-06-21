class AssociateMetersAndUserTariffs < ActiveRecord::Migration[6.0]
  def change
    create_table :meters_user_tariffs, id: false do |t|
      t.belongs_to :meter
      t.belongs_to :user_tariff
    end
  end
end
