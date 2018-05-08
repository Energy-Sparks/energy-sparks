VCR.configure do |config|
  # When running javascript tests, ignore any calls to the
  # test server!
  config.ignore_request do |request|
    URI(request.uri).port == 9516 || URI(request.uri).port == 7777
  end

  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end
