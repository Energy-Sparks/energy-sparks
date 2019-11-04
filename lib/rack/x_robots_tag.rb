module Rack
  class XRobotsTag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      if no_crawling?
        headers["X-Robots-Tag"] = "none"
      end

      [status, headers, response]
    end

    private

    def no_crawling?
      ! ENV.key?("ALLOW_CRAWLING")
    end
  end
end
