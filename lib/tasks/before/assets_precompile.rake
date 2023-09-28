namespace :before do

task before_assets_precompile: :environment do
  # run a command which starts your packaging
  system('yarn')
end

# Every time you execute 'rake assets:precompile'
# run 'before_assets_precompile' first
Rake::Task['assets:precompile'].enhance ['before_assets_precompile']
end