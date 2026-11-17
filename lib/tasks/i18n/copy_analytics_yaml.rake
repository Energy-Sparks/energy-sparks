namespace :i18n do
  desc 'copy YAML files from analytics to prepare a release'
  task :copy_analytics_yaml, :dir do |t,args|
    #provide a sensible default if not specified
    args.with_defaults(dir: Rails.root.join('config', 'locales', 'en', 'analytics'))
    dest = args.dir

    analytics_gem_path = `bundle info energy-sparks_analytics --path`.chomp
    analytics_yaml = File.join(analytics_gem_path, 'config', 'locales')
    $stderr.puts "Copying files from #{analytics_yaml} to #{dest}"

    #Copy all of the analytics YAML files, excluding any named with a x- prefix,
    #e.g. x-activesupport-dates.yml
    yaml = Dir["**/*.yml", base: analytics_yaml].reject {|f| f.match /^x-/}.sort
    yaml.each do |yml|
      FileUtils.cp File.join(analytics_gem_path, 'config', 'locales', yml), File.join(dest, yml)
    end

    $stderr.puts "Done. Check in the updated files before the release"
  end
end
