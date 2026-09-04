# frozen_string_literal: true

# rubocop:disable-next Metrics/BlockLength
namespace :database do
  desc 'Populate parsed_date in amr_data_feed_readings'
  task populate_parsed_date: :environment do
    puts "#{DateTime.now.utc} Starting population of parsed dates"

    batch_size = 20_000
    conn = ActiveRecord::Base.connection

    AmrDataFeedReading
      .joins(:amr_data_feed_config)
      .where(parsed_date: nil)
      .select(:id, :reading_date, :date_format)
      .find_in_batches(batch_size: batch_size) do |batch|
      rows = batch.filter_map do |row|
        parsed_date = AmrDataFeedConfig.date_from_string_using_date_format(row.reading_date, row.date_format)
        next unless parsed_date

        # Build a VALUES tuple: (id, 'parsed_date')
        "(#{row.id}, #{conn.quote(parsed_date)}::date)"
      end

      next if rows.empty?

      sql = <<~SQL.squish
        UPDATE amr_data_feed_readings AS t
        SET parsed_date = v.parsed_date
        FROM (
          VALUES #{rows.join(',')}
        ) AS v(id, parsed_date)
        WHERE t.id = v.id
      SQL

      conn.execute(sql)
      puts "#{DateTime.now.utc} Inserted batch"
    end

    puts "#{DateTime.now.utc} Completed population of parsed dates"
  rescue StandardError => e
    puts e
    puts e.backtrace
    EnergySparks::Log.exception(e, job: :populate_parsed_date)
  end
end
