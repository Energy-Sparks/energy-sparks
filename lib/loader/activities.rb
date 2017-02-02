require 'csv'

module Loader
  class Activities
    # load schools from csv
    def self.load!(csv_file)
      raise 'File not found' unless File.exist?(csv_file)
      CSV.foreach(csv_file, headers: true) do |row|
        category = ActivityCategory.find_or_create_by!(name: row['Activity Category'])
        activity_type = ActivityType.find_or_create_by!(name: row['Activity Type'], activity_category: category)
      end
    end
  end
end
