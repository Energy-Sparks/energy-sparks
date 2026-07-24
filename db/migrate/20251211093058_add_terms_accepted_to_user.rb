class AddTermsAcceptedToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :terms_accepted, :boolean, default: false
  end
end
