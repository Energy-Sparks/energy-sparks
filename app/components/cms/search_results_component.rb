module Cms
  class SearchResultsComponent < ApplicationComponent
    def initialize(query:, results:)
      super
      @query = query
      @results = results
    end
  end
end
