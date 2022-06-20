module Transifex
  #Stub for full implementation
  #Higher level service interface over the basic
  #Transifex client library
  class Service
    def initialize(api_client = nil)
      @api_client = api_client
    end

    #Is the resource fully translated?
    #Is reviewed_strings == total_strings?
    def reviews_completed?(_slug)
      false
    end

    #last_review_date statistic as a DateTime
    def last_reviewed(_slug)
      Time.zone.now
    end

    #create resource in tx
    #adding categories and other params
    #throw exception if problem
    #return true if created ok
    def create_resource(_name, _slug, _categories = [])
      true
    end

    #Upload this version of the resource to tx
    #Convert the object to YAML
    #Create async upload
    #Poll until upload completed
    #Raise exception if problem
    def push(_slug, _data)
      true
    end

    #Pull reviewed translations from tx
    #Convert the object to YAML
    #Create async download of reviewed translationed
    #Poll until download ready
    #Parse YAML
    #Raise exception if problem
    def pull(_slug, _locale)
      {}
    end
  end
end
