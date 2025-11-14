namespace :school do
  desc 'Assign schools to diocese'
  task :assign_diocese, [:path] => :environment do |_t, _args|
    School.find_each do |school|
      SchoolGrouping.assign_diocese(school)
    end
  end
end
