namespace :i18n do

  desc 'copy YAML files from analytics to prepare a release'
  task :copy_analytics_yaml, :dir do |t,args|
    #provide a sensible default if not specified
    args.with_defaults(dir: Rails.root.join('config', 'locales', 'analytics'))
    dest = args.dir

    analytics_gem_path = `bundle info energy-sparks_analytics --path`.chomp
    analytics_yaml = File.join(analytics_gem_path, 'config', 'locales')
    $stderr.puts "Copying files from #{dest} to #{analytics_yaml}"

    FileUtils.cp_r "#{analytics_yaml}/.", dest

    $stderr.puts "Done. Check in the updated files before the release"
  end

end
