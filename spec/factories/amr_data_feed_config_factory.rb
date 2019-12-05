FactoryBot.define do
  factory :amr_data_feed_config do
    source_type                   { :email }
    date_format                   { "%b %e %Y %I:%M%p" }
    description                   { |n| "Email data feed-#{n}" }
    mpan_mprn_field               { 'M1_Code1' }
    reading_date_field            { 'Date' }
    number_of_header_rows         { 1 }
    provider_id_field             { 'ID' }
    msn_field                     { 'M1_Code2' }
    total_field                   { 'Total Units' }
    meter_description_field       { 'Location' }
    postcode_field                { 'PostCode' }
    units_field                   { 'Units' }
    header_example                { "ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2" }
    reading_fields                { "[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00]".split(',') }
    sequence(:identifier)         { |n| "bucket-#{n}" }
  end
end
