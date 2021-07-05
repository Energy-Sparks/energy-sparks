class AddCclToUserTariffs < ActiveRecord::Migration[6.0]
  def change
    add_column :user_tariffs,:ccl, :boolean, default: false
  end
end
