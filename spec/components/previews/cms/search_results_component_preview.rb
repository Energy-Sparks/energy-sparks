module Cms
  class SearchResultsComponentPreview < ViewComponent::Preview
    # @param query
    # @param show_all
    def default(query: 'Lorem ipsum', show_all: false)
      results = Cms::Section.search(query: query, show_all: show_all)
      render(Cms::SearchResultsComponent.new(query: query, results: results))
    end
  end
end
