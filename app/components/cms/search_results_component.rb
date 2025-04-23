module Cms
  class SearchResultsComponent < ApplicationComponent
    def initialize(query:, results:, **kwargs)
      super
      @query = query
      @results = results
    end
  end
end
