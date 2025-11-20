namespace :school do
  desc 'Assign schools to local authority areas'
  task :load_and_assign_areas, [:path] => :environment do |_t, _args|
    Lists::Establishment.sync_local_authority_groups

    #    School.active.find_each do |school|
    #      SchoolGrouping.assign_area(school)
    #    end
  end
end
