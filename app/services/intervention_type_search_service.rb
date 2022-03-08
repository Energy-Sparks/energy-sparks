class InterventionTypeSearchService
  def self.search(query)
    intervention_types = InterventionType.active.search(query)
    intervention_types.with_pg_search_rank.distinct
  end
end
