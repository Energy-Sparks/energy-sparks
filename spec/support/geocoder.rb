Geocoder.configure(lookup: :test, ip_lookup: :test)

Geocoder::Lookup::Test.add_stub(
  "EH99 1SP", [
    {
      'coordinates'  => [55.952221, -3.174625],
      'country'      => 'scotland',
      'postal_code'  => 'EH99 1SP',
      'latitude'     => 55.952221,
      'longitude'    => -3.174625
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  "AB1 2CD", [
    {
      'coordinates'  => [55.952221, -3.174625],
      'country'      => 'england',
      'postal_code'  => 'AB1 2CD',
      'latitude'     => 51.340620,
      'longitude'    => -2.301420
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  "OL84JZ", [
    {
      'coordinates'  => [55.952221, -3.174625],
      'country'      => 'england',
      'postal_code'  => 'OL84JZ',
      'latitude'     => 51.340620,
      'longitude'    => -2.301420
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  "OL8 4JZ", [
    {
      'coordinates'  => [55.952221, -3.174625],
      'country'      => 'england',
      'postal_code'  => 'OL8 4JZ',
      'latitude'     => 51.340620,
      'longitude'    => -2.301420
    }
  ]
)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'     => nil,
      'longitude'    => nil,
      'country'      => nil
    }
  ]
)
