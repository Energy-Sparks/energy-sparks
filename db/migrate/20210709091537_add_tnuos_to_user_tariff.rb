class AddTnuosToUserTariff < ActiveRecord::Migration[6.0]
  def change
    add_column :user_tariffs,:tnuos, :boolean, default: false
  end
end
