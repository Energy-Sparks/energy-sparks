class RemoveTermsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :terms
  end
end
