module Transifex
  class Service
    MAX_TRIES     = 5
    SLEEP_SECONDS = 5

    def initialize(client = Service.create_client, max_tries = MAX_TRIES, sleep_seconds = SLEEP_SECONDS)
      @client = client
      @max_tries = max_tries
      @sleep_seconds = sleep_seconds
    end

    def self.create_client(api_key = ENV['TRANSIFEX_API_KEY'], project = ENV['TRANSIFEX_PROJECT'])
      Transifex::Client.new(api_key, project)
    end

    # Is the resource fully translated?
    # Is reviewed_strings == total_strings?
    def reviews_completed?(slug, locale)
      data = @client.get_resource_language_stats(slug, locale)
      data['attributes']['reviewed_strings'] == data['attributes']['total_strings']
    end

    # last_review_date statistic as a DateTime
    def last_reviewed(slug, locale)
      resp = @client.get_resource_language_stats(slug, locale)
      ts = resp['attributes']['last_review_update']
      ts.present? ? DateTime.parse(ts) : nil
    end

    def created_in_transifex?(slug)
      @client.get_resource(slug)
      true
    rescue Transifex::Client::NotFound
      false
    end

    # create resource in tx
    # adding categories and other params
    # throw exception if problem
    # return true if created ok
    def create_resource(name, slug, categories = [])
      @client.create_resource(name, slug, categories)
    end

    def push(slug, data)
      create_resp = @client.create_resource_strings_async_upload(slug, YAML.dump(data))
      @max_tries.times do
        resp = @client.get_resource_strings_async_upload(create_resp['id'])
        return true if resp.completed?

        sleep(@sleep_seconds)
      end
      false
    end

    def pull(slug, locale)
      create_resp = @client.create_resource_translations_async_downloads(slug, locale)
      @max_tries.times do
        resp = @client.get_resource_translations_async_download(create_resp['id'])
        return YAML.safe_load(resp.content) if resp.completed?

        sleep(@sleep_seconds)
      end
      false
    end

    def clear_resources
      items = @client.list_resources
      items.each do |item|
        @client.delete_resource(item['attributes']['slug'])
      end
      true
    end

    private

    def error_messages(errors)
      errors.map { |error| error['code'] + ': ' + error['detail'] }.join('\n')
    end
  end
end
