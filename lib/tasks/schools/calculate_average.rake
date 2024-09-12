# frozen_string_literal: true

namespace :school do
  desc 'Calculate average school'
  task calculate_average: :environment do
    data = CalculateAverageSchool.perform(logger: Logger.new($stdout))
    File.write('tmp/average_school_data.yaml', data.to_yaml)
  end
end
