module Transifex
  class Service
    SLEEP_SECONDS = 5

    def initialize(client = Service.create_client)
      @client = client
    end

    def self.create_client(api_key = ENV["TRANSIFEX_API_KEY"], project = ENV["TRANSIFEX_PROJECT"])
      Transifex::Client.new(api_key, project)
    end

    #Is the resource fully translated?
    #Is reviewed_strings == total_strings?
    def reviews_completed?(slug, locale)
      data = @client.get_resource_language_stats(slug, locale)
      data["attributes"]["reviewed_strings"] == data["attributes"]["total_strings"]
    end

    #last_review_date statistic as a DateTime
    def last_reviewed(slug, locale)
      resp = @client.get_resource_language_stats(slug, locale)
      ts = resp["attributes"]["last_review_update"]
      ts.present? ? DateTime.parse(ts) : nil
    end

    #create resource in tx
    #adding categories and other params
    #throw exception if problem
    #return true if created ok
    def create_resource(name, slug, categories = [])
      @client.create_resource(name, slug, categories)
    end

    def push(slug, data)
      create_resp = @client.create_resource_strings_async_upload(slug, YAML.dump(data))
      resp = @client.get_resource_strings_async_upload(create_resp["id"])
      until resp.completed?
        sleep(SLEEP_SECONDS)
        resp = @client.get_resource_strings_async_upload(create_resp["id"])
      end
      true
    end

    def pull(slug, locale)
      create_resp = @client.create_resource_translations_async_downloads(slug, locale)
      resp = @client.get_resource_translations_async_download(create_resp["id"])
      until resp.completed?
        #Make this configurable?
        sleep(SLEEP_SECONDS)
        resp = @client.get_resource_translations_async_download(create_resp["id"])
      end
      YAML.safe_load(resp.content).deep_transform_keys(&:to_sym)
    end

    private

    def error_messages(errors)
      errors.map { |error| error["code"] + ": " + error["detail"] }.join('\n')
    end
  end
end
