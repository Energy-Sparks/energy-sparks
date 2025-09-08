# Not sure where this should go in the source code hierarchy
# school_factory.rb - but thats in 'test support'? TODO(PH,JJ,1Dec2018)
class AnalyticsLoadSchools
  def self.load_schools(school_list)
    school_list.map do |school_attribute|
      load_school(school_attribute)
    end
  end

  def load_school(school_attribute)
    school = nil
    identifier_type, identifier = school_attribute.first
    bm = Benchmark.measure {
      school = $SCHOOL_FACTORY.load_or_use_cached_meter_collection(identifier_type, identifier, :analytics_db)
    }
    Logging.logger.info "Loaded School: #{identifier_type} #{identifier} in #{bm.to_s}"
    school
  end
end
