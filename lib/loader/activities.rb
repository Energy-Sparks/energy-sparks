require 'csv'

module Loader
  class Activities
    # load schools from csv
    def self.load!(csv_file)
      raise 'File not found' unless File.exist?(csv_file)
      CSV.foreach(csv_file, headers: true) do |row|
        category = ActivityCategory.find_or_create_by!(name: row['Activity Category'])
        at = ActivityType.find_by(name: row['Activity Type'], activity_category: category)
        if at.present?
          at.update_attributes!(score: row['Score'])
        else
          ActivityType.create!(name: row['Activity Type'], activity_category: category, score: row['Score'])
        end
      end
    end
  end
end
