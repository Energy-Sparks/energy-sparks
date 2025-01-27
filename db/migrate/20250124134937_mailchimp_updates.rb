class MailchimpUpdates < ActiveRecord::Migration[7.1]
  def change
    create_enum :mailchimp_update_status, ['pending', 'processed']
    create_enum :mailchimp_update_type, ['update_contact', 'archive_contact', 'update_contact_tags']

    create_table :mailchimp_updates do |t|
      t.references :user, null: false
      t.enum :update_type, enum_type: :mailchimp_update_type
      t.enum :status, enum_type: :mailchimp_update_status
      t.text :status_note, null: true
      t.date :processed_at, null: true
      t.timestamps
    end

    add_index :mailchimp_updates, [:user_id, :status, :update_type], unique: true
  end
end
