namespace :data_sources do
  desc 'Send a daily email when there is a data source that has exceeded it\'s alert threshold'
  task lagging_data_sources_alert: :environment do
    next unless ENV['SEND_AUTOMATED_EMAILS'] == 'true'

    lagging = DataSource.all.find_each.filter_map do |data_source|
      percentage_lagging = data_source.percentage_of_lagging_meters
      data_source if percentage_lagging > data_source.alert_percentage_threshold && data_source.alerts_on
    end
    AdminMailer.with(to: 'operations@energysparks.uk', lagging:).lagging_data_sources.deliver if lagging.present?
  end
end
