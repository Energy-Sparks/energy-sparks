namespace :school do
  desc 'Download GIAS data, update Establishments, and try to match existing Schools with Establishments'
  task :load_and_match_gias_schools => [:download_gias_data, :import_establishments, :match_establishments]
end
