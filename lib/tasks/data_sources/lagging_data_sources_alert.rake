namespace :data_sources do
  desc 'Send a daily email when there is a data source that has exceeded it\'s alert threshold'
  task lagging_data_sources_alert: :environment do
    next unless ENV['SEND_AUTOMATED_EMAILS'] == 'true'

    lagging = DataSource.all_find_each.filter_map(&:exceeded_alert_threshold?)

    AdminMailer.with(to: 'operations@energysparks.uk', lagging:).lagging_data_sources.deliver if lagging.present?
  end
end
