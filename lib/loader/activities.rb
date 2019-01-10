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
          # rubocop:disable Rails/ActiveRecordAliases
          at.update_attributes!(score: row['Score'])
          # rubocop:enable  Rails/ActiveRecordAliases
        else
          ActivityType.create!(name: row['Activity Type'], activity_category: category, score: row['Score'])
        end
      end
    end

    def self.load_progression!(csv_file)
      raise 'File not found' unless File.exist?(csv_file)
      ActivityTypeSuggestion.destroy_all
      CSV.foreach(csv_file, headers: true) do |row|
        if row['id'].blank?
          5.times do |i|
            ActivityTypeSuggestion.create!(activity_type_id: nil, suggested_type_id: row["suggestion_#{i + 1}"].to_i)
          end
        else
          at = ActivityType.find_by_id(row['id'])
          puts "Activity #{row['id']} not found" unless at
          if at
            #new properties
            at.data_driven = true if row['data_driven'] == "1"
            at.repeatable = true if row['repeatable'] == "1"
            at.custom = true if row['custom'] == "1"
            at.save!

            #now suggestions
            5.times do |i|
              suggested = ActivityType.find_by_id(row["suggestion_#{i + 1}"])
              puts "Skipping suggestion suggestion_#{i + 1} (#{row["suggestion_#{i + 1}"]}) for #{at.id}" unless suggested
              ActivityTypeSuggestion.create!(activity_type: at, suggested_type: suggested) if suggested
            end

          end
        end
      end
    end
  end
end
