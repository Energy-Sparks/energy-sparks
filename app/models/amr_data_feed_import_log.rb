# frozen_string_literal: true

# == Schema Information
#
# Table name: amr_data_feed_import_logs
#
#  id                      :bigint(8)        not null, primary key
#  error_messages          :text
#  file_name               :text
#  import_time             :datetime
#  records_imported        :integer
#  records_updated         :integer          default(0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  amr_data_feed_config_id :bigint(8)        not null
#
# Indexes
#
#  index_amr_data_feed_import_logs_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_amr_data_feed_import_logs_on_import_time              (import_time)
#

class AmrDataFeedImportLog < ApplicationRecord
  SUMMARY_PERIOD_IN_DAYS = 30.days

  has_many :amr_data_feed_readings
  has_many :amr_reading_warnings, dependent: :delete_all
  has_many :meters, -> { distinct }, through: :amr_data_feed_readings

  belongs_to :amr_data_feed_config

  scope :errored,       -> { where.not(error_messages: nil) }
  scope :with_warnings, lambda {
    joins(:amr_reading_warnings).distinct
  }
  scope :without_warnings, lambda {
    where.missing(:amr_reading_warnings)
  }
  scope :successful, -> { where(error_messages: nil).without_warnings }

  scope :recent, ->(date = SUMMARY_PERIOD_IN_DAYS.ago) { where(import_time: date..) }

  scope :unused, lambda {
    where.missing(:amr_data_feed_readings)
  }

  has_one :amr_uploaded_reading,
          primary_key: :file_name,
          foreign_key: :file_name,
          inverse_of: :amr_data_feed_import_log

  # rubocop:disable-next Metrics/MethodLength
  def self.recent_import_stats_for_config(amr_data_feed_config, cutoff = SUMMARY_PERIOD_IN_DAYS.ago)
    select(<<~SQL.squish)
      COUNT(*) AS total_count,

      COUNT(*) FILTER (
        WHERE logs.error_messages IS NULL
          AND logs.has_warnings = false
      ) AS successful_count,

      COUNT(*) FILTER (
        WHERE logs.error_messages IS NULL
          AND logs.has_warnings = true
      ) AS with_warnings_count,

      COUNT(*) FILTER (
        WHERE logs.error_messages IS NOT NULL
      ) AS error_count
    SQL
      .from(
        sanitize_sql_array(
          [
            <<~SQL.squish,
              (
                SELECT
                  logs.id,
                  logs.error_messages,
                  EXISTS (
                    SELECT 1
                    FROM amr_reading_warnings warnings
                    WHERE warnings.amr_data_feed_import_log_id = logs.id
                    LIMIT 1
                  ) AS has_warnings
                FROM amr_data_feed_import_logs logs
                WHERE logs.amr_data_feed_config_id = ?
                  AND logs.import_time >= ?
              ) AS logs
            SQL
            amr_data_feed_config.id,
            cutoff
          ]
        )
      )
      .take
  end

  def errors?
    error_messages.present?
  end

  def warnings?
    amr_reading_warnings.any?
  end
end
