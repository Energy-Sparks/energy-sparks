# frozen_string_literal: true

require 'csv'

module Loader
  class Schools
    # load schools from csv
    def self.load!(csv_file)
      raise 'File not found' unless File.exist?(csv_file)
      CSV.foreach(csv_file, headers: true) do |row|
        # create new school unless school with this URN exists
        unless School.find_by(urn: row['URN'])
          School.create(
            urn: row['URN'],
            name: row['Name'],
            school_type: row['Type'].try(:to_sym),
            address: row['Address'],
            postcode: row['Postcode'],
            website: row['Website']
          )
        end
      end
    end
  end
end
