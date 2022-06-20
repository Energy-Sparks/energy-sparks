module Transifex
  class TranslationsUploadError < StandardError; end
  #Stub for full implementation
  #Higher level service interface over the basic
  #Transifex client library
  class Service
    COMPLETED = %w{failed success}.freeze

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

    def push(_slug, _data)
      # create_resp = @client.create_resource_strings_async_upload(slug, YAML.dump(data))
      # resp = @client.get_resource_strings_async_upload(create_resp["id"])
      # #Should we have max retries?
      # until COMPLETED.include?(resp["attributes"]["status"])
      #   #Make this configurable?
      #   sleep(5)
      #   resp = @client.get_resource_strings_async_upload(create_resp["id"])
      # end
      # if resp["attributes"]["status"] == "failed"
      #   errors = data['attributes']['errors'].present? ? error_messages(data['attributes']['errors']) : ""
      #   raise TranslationsUploadError("#{slug}, errors: #{errors}")
      # end
      true
    end

    #Pull reviewed translations from tx
    #Convert the object to YAML
    #Create async download of reviewed translationed
    #Poll until download ready
    #Parse YAML
    #Raise exception if problem
    def pull(slug, locale)
      create_resp = @client.create_resource_translations_async_downloads(slug, locale)
      resp = @client.get_resource_translations_async_download(create_resp["id"])
      YAML.safe_load(resp).deep_transform_keys(&:to_sym)
    end

    private

    def error_messages(errors)
      errors.map { |error| error["code"] + ": " + error["detail"] }.join('\n')
    end
  end
end
