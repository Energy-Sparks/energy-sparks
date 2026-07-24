# frozen_string_literal: true

namespace :school do # rubocop:disable Metrics/BlockLength
  desc 'Download establishment data from get-information-schools.service.gov.uk'
  task :download_gias_data, %i[refresh_attempts path] => :environment do |_t, args| # rubocop:disable Metrics/BlockLength
    def download_when_ready(agent, args)
      # After being redirected, auto refresh on an interval until the download form appears
      success = args[:refresh_attempts].to_i.times.any? do |attempt|
        puts "Waiting 3 seconds... (#{attempt + 1}/#{args[:refresh_attempts]})"
        sleep 3
        page = agent.get(agent.page.uri)
        if page.body.include?('Download generation completed')
          form = agent.page.form_with(action: '/Downloads/Download/Extract')
          form.click_button(form.button_with(id: 'download-button')).save!(args[:path])
          puts "Successfully saved at #{args[:path]}"
          true
        else
          false
        end
      end
      warn "Timed out after #{args[:refresh_attempts]} attempts" unless success
    end

    args.with_defaults(refresh_attempts: 5, path: 'tmp/gias_download.zip')
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    url = 'http://get-information-schools.service.gov.uk/Downloads'
    puts "Getting page from #{url}"
    agent.get(url)
    form = agent.page.form_with(action: '/Downloads/Collate')
    form.checkbox_with(id: 'establishment-fields-csv-checkbox').check
    form.checkbox_with(id: 'establishment-links-csv-checkbox').check
    form.click_button(form.button_with(id: 'download-selected-files-button'))
    puts 'Submitted form, waiting for download'
    download_when_ready(agent, args)
  rescue StandardError => e
    EnergySparks::Log.exception(e, {})
    raise
  end
end
