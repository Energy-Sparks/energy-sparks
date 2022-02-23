class ActivityTypeSearchService
  def self.search(query, key_stages = [], subjects = [])
    activity_types = ActivityType.search(query)
    activity_types = activity_types.for_key_stages(key_stages) if key_stages.present?
    activity_types = activity_types.for_subjects(subjects) if subjects.present?
    activity_types.with_pg_search_rank.distinct
  end
end
