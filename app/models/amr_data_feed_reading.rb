# == Schema Information
#
# Table name: amr_data_feed_readings
#
#  amr_data_feed_config_id     :bigint(8)        not null
#  amr_data_feed_import_log_id :bigint(8)        not null
#  created_at                  :datetime         not null
#  description                 :text
#  id                          :bigint(8)        not null, primary key
#  meter_id                    :bigint(8)
#  meter_serial_number         :text
#  mpan_mprn                   :text             not null
#  postcode                    :text
#  provider_record_id          :text
#  reading_date                :text             not null
#  reading_time                :text
#  readings                    :text             not null, is an Array
#  school                      :text
#  total                       :text
#  type                        :text
#  units                       :text
#  updated_at                  :datetime         not null
#
# Indexes
#
#  adfr_meter_id_config_id                                      (meter_id,amr_data_feed_config_id)
#  index_amr_data_feed_readings_on_amr_data_feed_config_id      (amr_data_feed_config_id)
#  index_amr_data_feed_readings_on_amr_data_feed_import_log_id  (amr_data_feed_import_log_id)
#  index_amr_data_feed_readings_on_meter_id                     (meter_id)
#  index_amr_data_feed_readings_on_meter_id_and_created_at      (meter_id,created_at)
#  index_amr_data_feed_readings_on_mpan_mprn                    (mpan_mprn)
#  unique_meter_readings                                        (mpan_mprn,reading_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#  fk_rails_...  (amr_data_feed_import_log_id => amr_data_feed_import_logs.id) ON DELETE => cascade
#  fk_rails_...  (meter_id => meters.id) ON DELETE => nullify
#

# Postgres autovacuum specific settings:
# See: https://www.postgresql.org/docs/current/runtime-config-autovacuum.html
# Applied using: ALTER TABLE amr_data_feed_readings SET (X = n)
# autovacuum_vacuum_cost_delay = 0
# autovacuum_analyze_scale_factor = 0
# autovacuum_analyze_threshold = 10000
# autovacuum_vacuum_scale_factor = 0
# autovacuum_vacuum_threshold = 50000
class AmrDataFeedReading < ApplicationRecord
  belongs_to :meter, optional: true
  belongs_to :amr_data_feed_import_log
  belongs_to :amr_data_feed_config

  CSV_HEADER_DATA_FEED_READING = 'School URN,Name,Mpan Mprn,Meter Type,Reading Date,Reading Date Format,Record Last Updated,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'.freeze

  PARSED_DATE = <<~SQL.squish.freeze
    CASE
    WHEN reading_date ~ '\\d{4}/\\d{1,2}/\\d{1,2}' THEN to_date(reading_date, 'YYYY/MM/DD')
    WHEN reading_date ~ '\\d{1,2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-\\d{2}' THEN to_date(reading_date, 'DD-MON-YY')
    WHEN date_format='%d %b %Y %H:%M:%S' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%d-%b-%y' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%d-%m-%Y' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%Y%m%d' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%d/%m/%Y %H:%M:%S' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY/MM/DD')
    WHEN date_format='%d-%m-%Y' THEN to_date(reading_date, 'DD-MM-YYYY')
    WHEN date_format='%d/%m/%Y' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%d/%m/%Y' THEN to_date(reading_date, 'DD/MM/YYYY')
    WHEN date_format='%d/%m/%y' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%d/%m/%y' THEN to_date(reading_date, 'DD/MM/YY')
    WHEN date_format='%Y-%m-%d' AND reading_date~'\\d{2}/\\d{2}/\\d{4}' THEN to_date(reading_date, 'DD/MM/YYYY')
    WHEN date_format='%Y-%m-%d' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%Y-%m-%d' THEN to_date(reading_date, 'YYYY-MM-DD ')
    WHEN date_format='%y-%m-%d' THEN to_date(reading_date, 'YY-MM-DD ')
    WHEN date_format='"%d-%m-%Y"' THEN to_date(reading_date, '"DD-MM-YYYY"')
    WHEN date_format='%d/%m/%Y %H:%M:%S' THEN to_date(reading_date, 'DD/MM/YYYY HH24:MI::SS')
    WHEN date_format='%H:%M:%S %a %d/%m/%Y' THEN to_date(reading_date, 'HH24:MI::SS Dy DD/MM/YYYY')
    WHEN date_format='%e %b %Y %H:%M:%S' AND reading_date~'\\d{4}-\\d{2}-\\d{2}' THEN to_date(reading_date, 'YYYY-MM-DD')
    WHEN date_format='%e %b %Y %H:%M:%S' THEN to_date(reading_date, 'DD Mon YYYY HH24:MI::SS')
    WHEN date_format='%b %e %Y %I:%M%p' THEN to_date(reading_date, 'Mon DD YYYY HH12:MIam')
    ELSE NULL
    END parsed_date
  SQL

  def self.download_all_data
    <<~QUERY
      SELECT s.urn,
             s.name,
             m.mpan_mprn,
             CASE m.meter_type WHEN 0 THEN 'Electricity' WHEN 1 THEN 'Gas' WHEN 2 THEN 'Solar PV' WHEN 3 THEN 'Exported Solar PV' END,
             amr.reading_date,
             c.date_format,
             amr.updated_at,
             amr.readings
      FROM  amr_data_feed_readings amr, meters m, schools s, amr_data_feed_configs c
      WHERE amr.meter_id = m.id
      AND   m.school_id  = s.id
      AND   amr.amr_data_feed_config_id = c.id
      ORDER BY s.id, m.mpan_mprn ASC
    QUERY
  end

  def self.download_query_for_school(school_id)
    <<~QUERY
      SELECT s.urn,
             s.name,
             m.mpan_mprn,
             CASE m.meter_type WHEN 0 THEN 'Electricity' WHEN 1 THEN 'Gas' WHEN 2 THEN 'Solar PV' WHEN 3 THEN 'Exported Solar PV' END,
             amr.reading_date,
             c.date_format,
             amr.updated_at,
             amr.readings
      FROM  amr_data_feed_readings amr, meters m, schools s, amr_data_feed_configs c
      WHERE amr.meter_id = m.id
      AND   m.school_id  = s.id
      AND   s.id         = #{school_id}
      AND   amr.amr_data_feed_config_id = c.id
      ORDER BY s.id, m.mpan_mprn ASC
    QUERY
  end

  def self.meter_loading_report(mpxn)
    where(mpan_mprn: mpxn).joins(
      :amr_data_feed_import_log,
      :amr_data_feed_config,
      'LEFT JOIN amr_uploaded_readings ON amr_uploaded_readings.file_name = amr_data_feed_import_logs.file_name'
    ).select(
      :created_at,
      :reading_date,
      'amr_data_feed_import_logs.file_name',
      :amr_data_feed_import_log_id,
      :amr_data_feed_config_id,
      'amr_data_feed_configs.identifier',
      'amr_data_feed_configs.source_type', 'amr_uploaded_readings.imported',
      PARSED_DATE
    ).order(
      parsed_date: :desc,
      created_at: :desc
    )
  end

  def self.build_unvalidated_data_report_query(mpans, amr_data_feed_config_ids)
    amr_data_feed_config_ids = amr_data_feed_config_ids.reject { |id| id.blank? || id.zero? }
    amr_data_feed_config_ids = AmrDataFeedConfig.all.pluck(:id) if amr_data_feed_config_ids.empty?

    list_of_mpans = mpans.map {|m| "'#{m}'"}.join(',')
    list_of_amr_data_feed_config_ids = amr_data_feed_config_ids.map {|m| "'#{m}'"}.join(',')

    <<~QUERY
      SELECT mpan_mprn, meter_id, identifier, description, MIN(parsed_date) as earliest_reading, MAX(parsed_date) as latest_reading FROM (
        SELECT mpan_mprn, meter_id, identifier, amr_data_feed_configs.description, reading_date,
        #{PARSED_DATE}
        FROM amr_data_feed_readings
        JOIN amr_data_feed_configs ON amr_data_feed_configs.id = amr_data_feed_readings.amr_data_feed_config_id
        WHERE mpan_mprn IN (#{list_of_mpans}) AND amr_data_feed_readings.amr_data_feed_config_id IN (#{list_of_amr_data_feed_config_ids})
        ) as raw_data
      GROUP BY mpan_mprn, meter_id, identifier, description
      ORDER by mpan_mprn, meter_id, latest_reading DESC
    QUERY
  end

  def self.unvalidated_data_report_for_mpans(mpans, amr_data_feed_config_ids = [])
    query = build_unvalidated_data_report_query(mpans, amr_data_feed_config_ids)
    query_results = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql(query))
    sort_query_results_by(mpans, query_results)
  end

  def self.sort_query_results_by(mpans, query_results)
    mpans.uniq.each_with_object([]) do |mpan, rows|
      next if mpan.empty?

      rows_for_mpan = query_results.select { |result| result['mpan_mprn'] == mpan }
      if rows_for_mpan.present?
        rows_for_mpan.each { |row_for_mpan| rows << row_for_mpan }
      else
        # Add an empty row for for any MPAN/MPRN not found
        rows << { 'mpan_mprn' => mpan, 'meter_id' => '-', 'identifier' => '-', 'description' => '-', 'earliest_reading' => '-', 'latest_reading' => '-' }
      end
    end
  end
end
