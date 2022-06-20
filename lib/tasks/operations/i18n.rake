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

  desc 'generate transifex config .tx/config'
  task :generate_tx_config, :dir do |t,args|
    args.with_defaults(dir: Rails.root.join('.tx'))
    dest = args.dir

    FileUtils.mkdir_p(dest)
    File.open(File.join(dest, "config"), "w") do |f|
      f.puts "[main]"
      f.puts "host = https://www.transifex.com"
      f.puts
      yaml = Dir["**/*.yml", base: Rails.root.join("config", "locales")].reject {|f| f.match /cy/}.sort
      yaml.each do |yml|
        slug = yml.gsub(/\.|\//, '-')
        f.puts "[o:energy-sparks:p:energy-sparks:r:#{slug}]"
        f.puts "file_filter  = config/locales/<lang>/#{yml}"
        f.puts "source_file  = config/locales/#{yml}"
        f.puts "source_lang  = en"
        f.puts "type         = YML"
        f.puts "minimum_perc = 0"
        f.puts
      end
    end

  end

end
