namespace :school do
  desc 'Assign schools to diocese'
  task :assign_diocese, [:path] => :environment do |_t, _args|
    School.active.find_each do |school|
      SchoolGrouping.assign_diocese(school)
    end

    missing_codes = Lists::Establishment.missing_diocese
    Rollbar.warning('Missing Church of England diocese', missing_codes: missing_codes) if missing_codes.any?
  end
end
