class AddSiteSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :site_settings do |t|
      t.boolean :message_for_no_contacts, default: true
      t.timestamps
    end
  end
end
