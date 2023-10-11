namespace :i18n do
  desc 'generate transifex config .tx/config'
  task :generate_tx_config, :dir do |_t, args|
    args.with_defaults(dir: Rails.root.join('.tx'))
    dest = args.dir
    FileUtils.mkdir_p(dest)
    File.open(File.join(dest, 'config'), 'w') do |f|
      f.puts '[main]'
      f.puts 'host = https://www.transifex.com'
      f.puts
      yaml = Dir['**/*.yml', base: Rails.root.join('config', 'locales')].reject { |f| f.match(/^cy/) }.sort
      yaml.each do |yml|
        slug = yml.gsub(%r{\.|/}, '-')
        f.puts "[o:energy-sparks:p:energy-sparks:r:#{slug}]"
        f.puts "file_filter  = config/locales/<lang>/#{yml}"
        f.puts "source_file  = config/locales/#{yml}"
        f.puts 'source_lang  = en'
        f.puts 'type         = YML'
        f.puts 'minimum_perc = 100'
        f.puts
      end
    end
  end
end
