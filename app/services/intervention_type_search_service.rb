class InterventionTypeSearchService
  def self.search(query, locale = 'en')
    InterventionType.search(query: query, locale: locale)
  end
end
