class MailchimpUpdates < ActiveRecord::Migration[7.1]
  def change
    # Columns to track when Mailchimp relevant fields or associations
    # have been changed on this model
    add_column :users, :mailchimp_fields_changed_at, :datetime, null: true
    add_column :schools, :mailchimp_fields_changed_at, :datetime, null: true
    add_column :school_groups, :mailchimp_fields_changed_at, :datetime, null: true
    add_column :scoreboards, :mailchimp_fields_changed_at, :datetime, null: true
    add_column :funders, :mailchimp_fields_changed_at, :datetime, null: true
    add_column :local_authority_areas, :mailchimp_fields_changed_at, :datetime, null: true
    add_column :staff_roles, :mailchimp_fields_changed_at, :datetime, null: true

    # Date when mailchimp last updated for the user
    add_column :users, :mailchimp_updated_at, :datetime, null: true

    # For tracking status of contact in Mailchimp audience
    create_enum :mailchimp_status, ['subscribed', 'unsubscribed', 'cleaned', 'nonsubscribed']
    add_column :users, :mailchimp_status, :enum, enum_type: :mailchimp_status, null: true
  end
end
