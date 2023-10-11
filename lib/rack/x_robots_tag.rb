module Rack
  class XRobotsTag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      headers['X-Robots-Tag'] = 'none' if no_crawling?

      [status, headers, response]
    end

    private

    def no_crawling?
      !ENV.key?('ALLOW_CRAWLING')
    end
  end
end
