FactoryBot.define do
  factory :data_source do
    name { "MyString" }
    organisation_type { :energy_supplier }
    contact_name { "Contact name" }
    contact_email { "contact@email.com" }
    loa_contact_details { "Some text, could include an email address" }
    data_prerequisites { "Need to have list of MPANs and LOA" }
    data_feed_type { "30 day rolling csv file" }
    new_area_data_feed { "Ask the school or MAT to contact the Council" }
    add_existing_data_feed { "Send an email to Steve" }
    data_issues_contact_details { "Source Profile team" }
    historic_data { "Can be accessed via portal" }
    loa_expiry_procedure { "Send updated LOA to Source Profile team" }
    comments { "GDST data feed covers their whole portfolio" }
  end
end
