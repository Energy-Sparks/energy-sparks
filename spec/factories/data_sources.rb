FactoryBot.define do
  factory :data_source do
    name { "MyString" }
    organisation_type { "" }
    contact_name { "MyString" }
    email { "MyString" }
    loa_contact_details { "MyText" }
    data_prerequisites { "MyText" }
    data_feed_type { "MyString" }
    new_area_data_feed { "MyText" }
    add_existing_data_feed { "MyText" }
    data_issues_contact { "MyText" }
    historic_data { "MyText" }
    loa_expiry_procedure { "MyText" }
    comments { "MyText" }
  end
end
