module EnergySparks
  class FeatureFlags
    def self.active?(feature)
      ENV["FEATURE_FLAG_#{feature.to_s.upcase}"] == 'true'
    end
  end
end
