FactoryBot.define do
  factory :data_source do
    sequence(:name) {|n| "Data source name #{n}"}
    organisation_type { :energy_supplier }
    sequence(:contact_name) {|n| "Contact name #{n}" }
    sequence(:contact_email) {|n| "contact#{n}@email.com" }
    sequence(:loa_contact_details) {|n| "LOA contact details #{n}" }
    sequence(:data_prerequisites) {|n| "Data prerequisites #{n}" }
    sequence(:data_feed_type) {|n| "Data feed type #{n}" }
    sequence(:new_area_data_feed) {|n| "New are data feed #{n}" }
    sequence(:add_existing_data_feed) {|n| "Add existing data feed #{n}" }
    sequence(:data_issues_contact_details) {|n| "Data issues contact details #{n}" }
    sequence(:historic_data) {|n| "Historic data #{n}" }
    sequence(:loa_expiry_procedure) {|n| "LOA expiry procedure #{n}" }
    sequence(:comments) {|n| "Comments #{n}" }
  end
end
