namespace :school do
  desc "Calculate average school"
  task calculate_average: :environment do
    data = CalculateAverageSchool.perform
    File.write('tmp/average_school_data.yaml', data.to_yaml)
  end
end
