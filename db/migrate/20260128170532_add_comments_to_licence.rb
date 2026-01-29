class AddCommentsToLicence < ActiveRecord::Migration[7.2]
  def change
    add_column :commercial_licences, :comments, :text
  end
end
