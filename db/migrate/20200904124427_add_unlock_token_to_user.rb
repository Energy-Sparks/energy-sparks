class AddUnlockTokenToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :unlock_token, :string
  end
end
