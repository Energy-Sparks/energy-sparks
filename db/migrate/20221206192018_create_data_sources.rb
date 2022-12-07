class CreateDataSources < ActiveRecord::Migration[6.0]
  def change
    create_table :data_sources do |t|
      t.string :name, null:false
      t.integer :organisation_type
      t.string :contact_name
      t.string :contact_email
      t.text :loa_contact_details
      t.text :data_prerequisites
      t.string :data_feed_type
      t.text :new_area_data_feed
      t.text :add_existing_data_feed
      t.text :data_issues_contact_details
      t.text :historic_data
      t.text :loa_expiry_procedure
      t.text :comments

      t.timestamps
    end
  end
end
