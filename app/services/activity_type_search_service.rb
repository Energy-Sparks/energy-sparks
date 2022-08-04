class ActivityTypeSearchService
  def self.search(query, key_stages = [], subjects = [], locale = 'en')
    activity_types = ActivityType.active.search(query: query, locale: locale)
    activity_types = activity_types.for_key_stages(key_stages) if key_stages.present?
    activity_types = activity_types.for_subjects(subjects) if subjects.present?
    activity_types
  end
end
