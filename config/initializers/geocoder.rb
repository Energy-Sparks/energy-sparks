Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  # lookup: :nominatim,           # name of geocoding service (symbol)
  lookup: :postcodes_io,
  # ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  # language: :en,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,               # API key for geocoding service
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # pickpoint: { api_key: ENV['PICKPOINT_API_KEY'] },
  # bing: { api_key: ENV['BING_API_KEY'] }

  # Calculation options
  # units: :mi,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
)

if Rails.env.test?
  Geocoder.configure(lookup: :test, ip_lookup: :test)

  Geocoder::Lookup::Test.add_stub(
    "EH99 1SP", [
      {
        'coordinates'  => [55.952221, -3.174625],
        'address'      => 'Holyrood, Edinburgh, Scotland, EH99 1SP',
        'state'        => 'Edinburgh',
        'state_code'   => 'EH',
        'country'      => 'scotland',
        'country_code' => 'uk',
        'postal_code'     => 'EH99 1SP',
        'latitude'     => 55.952221,
        'longitude'    => -3.174625
      }
    ]
  )

  Geocoder::Lookup::Test.add_stub(
    "AB1 2CD", [
      {
        'coordinates'  => [55.952221, -3.174625],
        'address'      => 'Freshford Station',
        'state'        => 'Somerset',
        'state_code'   => 'EH',
        'country'      => 'england',
        'country_code' => 'uk',
        'postal_code'     => 'AB1 2CD',
        'latitude'     => 51.340620,
        'longitude'    => -2.301420
      }
    ]
  )

  Geocoder::Lookup::Test.add_stub(
    "OL84JZ", [
      {
        'coordinates'  => [55.952221, -3.174625],
        'address'      => 'Freshford Station',
        'state'        => 'Somerset',
        'state_code'   => 'EH',
        'country'      => 'england',
        'country_code' => 'uk',
        'postal_code'     => 'OL84JZ',
        'latitude'     => 51.340620,
        'longitude'    => -2.301420
      }
    ]
  )

  Geocoder::Lookup::Test.add_stub(
    "OL8 4JZ", [
      {
        'coordinates'  => [55.952221, -3.174625],
        'address'      => 'Freshford Station',
        'state'        => 'Somerset',
        'state_code'   => 'EH',
        'country'      => 'england',
        'country_code' => 'uk',
        'postal_code'     => 'OL8 4JZ',
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
end
