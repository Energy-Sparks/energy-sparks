class ActivityTypeSearchService
  def self.search(query, key_stages = [], subjects = [], locale = 'en')
    activity_types = if locale.to_s == 'en'
                       ActivityType.active.regular_search(query)
                     else
                       ActivityType.translatable_search(query, locale)
                     end
    activity_types = activity_types.for_key_stages(key_stages) if key_stages.present?
    activity_types = activity_types.for_subjects(subjects) if subjects.present?
    activity_types = activity_types.with_pg_search_rank.distinct if locale.to_s == 'en'
    activity_types
  end
end
