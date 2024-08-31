namespace :school do
  desc "Calculate average school"
  task calculate_average: :environment do
    data = CalculateAverageSchool.perform
    File.write('tmp/average_school_data.json', data.to_json)
  end
end
