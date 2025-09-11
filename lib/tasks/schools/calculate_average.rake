# frozen_string_literal: true

# This script is run annually, typically around September to regenerate data for
# app/models/schools/average_school_data.yaml.
namespace :school do
  desc 'Calculate average school'
  task calculate_average: :environment do
    data = CalculateAverageSchool.perform(logger: Logger.new($stdout))
    File.write('tmp/average_school_data.yaml', data.to_yaml)
  end
end
