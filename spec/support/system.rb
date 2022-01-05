RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # This switches off the puma debug in the test run
  Capybara.server = :puma, { Silent: true }

  # Currently fails two tests
  # Capybara.register_driver :headless_firefox do |app|
  #   options = ::Selenium::WebDriver::Firefox::Options.new
  #   options.args << '--headless'

  #   Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
  # end

  Capybara.register_driver :headless_chrome do |app|
    # options explained https://peter.sh/experiments/chromium-command-line-switches/
    # no-sandbox
    #   because the user namespace is not enabled in the container by default
    # headless
    #   run w/o actually launching gui
    # disable-gpu
    #   Disables graphics processing unit(GPU) hardware acceleration
    # window-size
    #   sets default window size in case the smaller default size is not enough
    #   we do not want max either, so this is a good compromise

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('headless')
    options.add_argument('no-sandbox')
    options.add_argument('disable-gpu')
    options.add_argument('disable-dev-shm-usage')
    options.add_argument('window-size=1400,10000')
    #now needs to be true, to get a session id?
    options.add_option('w3c', true)
    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: options)
  end

  config.before(:each, type: :system, js: true) do
    @supports_js = true

    driven_by :headless_chrome
    # driven_by :headless_firefox
    # page.driver.browser.manage.window.resize_to(2800,10000)
  end

  config.after(:each, type: :system, js: true) do |example|
    errors = page.driver.browser.logs.get(:browser)
    if errors.present? && !example.metadata.has_key?(:errors_expected)
      aggregate_failures 'javascript errors' do
        errors.each do |error|
          expect(error.level).not_to eq('SEVERE'), error.message
          next unless error.level == 'WARNING'
          STDERR.puts 'WARN: javascript warning'
          STDERR.puts error.message
        end
      end
    end
  end

end
