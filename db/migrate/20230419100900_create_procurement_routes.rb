class CreateProcurementRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :procurement_routes do |t|
      t.string :organisation_name, null:false
      t.string :contact_name
      t.string :contact_email
      t.string :loa_contact_details
      t.text :data_prerequisites
      t.text :new_area_data_feed
      t.text :add_existing_data_feed
      t.text :data_issues_contact_details
      t.text :loa_expiry_procedure
      t.text :comments
      t.timestamps
    end
  end
end
