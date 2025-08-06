namespace :school do
  desc 'Download establishment data from get-information-schools.service.gov.uk'
  task :download_gias_data, [:refresh_attempts, :path] => :environment do |_t, args|
    begin
      args.with_defaults(:refresh_attempts => 5, :path => 'tmp/gias_download.zip')

      agent = Mechanize.new
      agent.request_headers = { 'User-agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0' } # page returns a 403 error if the agent doesn't have a user agent header

      url = 'http://get-information-schools.service.gov.uk/Downloads'
      puts "Getting page from #{url}"
      agent.get(url)
      form = agent.page.form_with(:action => '/Downloads/Collate')
      form.checkboxes_with(:id => 'establishment-fields-csv-checkbox').first.checked = true
      form.checkboxes_with(:id => 'establishment-links-csv-checkbox').first.checked = true
      form.click_button(form.buttons_with(:id => 'download-selected-files-button').first)

      # After being redirected, auto refresh on an interval until the download form appears
      puts 'Submitted form, waiting for download'
      get_download agent
    rescue => e
      warn e
      EnergySparks::Log.exception(e, {})
    end
  end
end

def get_download(agent)
  attempt = 0
  loop do
    sleep 3
    puts 'Refreshing...'
    form = agent.get(agent.page.uri).form_with(:action => '/Downloads/Download/Extract')
    if form != nil
      file = form.click_button(form.buttons_with(:id => 'download-button').first)
      file.save!(args[:path])
      puts "Successfully saved at #{args[:path]}"
      break
    end
    attempt += 1
    if attempt == args[:refresh_attempts].to_i
      warn "Timed out after #{args[:refresh_attempts]} attempts"
      break
    end
  end
end
