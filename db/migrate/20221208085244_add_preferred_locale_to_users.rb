class AddPreferredLocaleToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :preferred_locale, :string, null: false, default: 'en'
  end
end
