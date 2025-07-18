# frozen_string_literal: true

module Schools
  module AverageSchoolData
    DATA = YAML.load_file(File.join(__dir__, 'average_school_data.yaml'))

    def self.raw_data
      DATA
    end
  end
end
