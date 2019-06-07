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

    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w[headless no-sandbox disable-gpu disable-dev-shm-usage window-size=1400,10000] }
    )

    Capybara::Selenium::Driver.new(
      app,
      browser:              :chrome,
      desired_capabilities: capabilities
    )
  end

  config.before(:each, type: :system, js: true) do

    driven_by :headless_chrome
    # driven_by :headless_firefox
    # page.driver.browser.manage.window.resize_to(2800,10000)
  end
end
